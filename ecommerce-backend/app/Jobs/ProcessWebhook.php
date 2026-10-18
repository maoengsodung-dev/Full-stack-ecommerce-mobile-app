<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\Payment;
use App\Services\OrderService;
use App\Services\PayWayService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Asynchronous follow-up of an already-verified webhook.
 *
 * Hash verification + initial DB write happens synchronously inside the
 * controller (so we always answer "OK" within the gateway's timeout).
 * Heavy operations such as sending the buyer email or scheduling
 * fulfilment are pushed here.
 */
class ProcessWebhook implements ShouldQueue, ShouldBeUnique
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public int $tries   = 5;
    public int $timeout = 60;

    public function __construct(
        public string $tranId,
        public array $rawPayload,
    ) {
        $this->onQueue('webhooks');
    }

    public function uniqueId(): string
    {
        return 'webhook:'.$this->tranId;
    }

    public function backoff(): array
    {
        return [15, 30, 60, 120, 300];
    }

    public function handle(PayWayService $payway, OrderService $orders): void
    {
        $payment = Payment::where('tran_id', $this->tranId)->first();
        if ($payment === null) {
            Log::channel('payway')->warning('Webhook payment not found', ['tran_id' => $this->tranId]);
            return;
        }

        $statusCode = $this->rawPayload['status']['code']
            ?? $this->rawPayload['status_code']
            ?? null;

        $mapped = $payway->mapStatusCode((string) $statusCode);

        if ($mapped['payment'] === Payment::STATUS_SUCCEEDED) {
            $orders->markPaidFromWebhook($payment, $this->rawPayload);
            return;
        }

        if ($mapped['payment'] === Payment::STATUS_FAILED) {
            $orders->markFailedFromWebhook(
                $payment,
                $this->rawPayload,
                (string) ($this->rawPayload['status']['message'] ?? 'Payment failed'),
            );
            return;
        }

        if ($mapped['payment'] === Payment::STATUS_CANCELLED) {
            $orders->markCancelledFromWebhook($payment, $this->rawPayload);
            return;
        }

        Log::channel('payway')->info('Webhook with non-final status', [
            'tran_id' => $this->tranId,
            'status'  => $statusCode,
        ]);
    }
}
