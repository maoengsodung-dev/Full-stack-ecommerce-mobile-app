<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Payment;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessWebhook;
use App\Models\Payment;
use App\Services\PayWayService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class PayWayWebhookController extends Controller
{
    public function __construct(
        private readonly PayWayService $payway,
    ) {
    }

    /**
     * ABA PayWay webhook.
     *
     * Critical: hash verification MUST happen BEFORE any DB write.
     * Per PayWay's spec, the signature comes in the X-PayWay-HMAC-SHA512
     * header and the JSON body is the canonical signed input. We rebuild
     * the hash from the body and compare it to the header. Only when it
     * matches do we accept the webhook.
     */
    public function __invoke(Request $request): Response
    {
        $payload = $request->json()->all() ?: $request->all();

        $providedHash = (string) $request->header('X-PayWay-HMAC-SHA512', '');
        $tranId       = (string) ($payload['tran_id'] ?? '');

        if ($providedHash === '' || $tranId === '') {
            Log::channel('payway')->warning('Webhook missing tran_id or signature header', $payload);
            return response('FAIL', 400);
        }

        if (! $this->payway->verifyWebhookSignature($payload, $providedHash)) {
            Log::channel('payway')->warning('Webhook hash verification failed', [
                'tran_id' => $tranId,
                'ip'      => $request->ip(),
            ]);
            return response('FAIL', 401);
        }

        // Hash is valid → record the webhook and dispatch async processor.
        $payment = Payment::where('tran_id', $tranId)->first();
        if ($payment !== null) {
            $payment->update([
                'webhook_response' => $payload,
                'status'           => $payment->status === Payment::STATUS_INITIATED
                    ? Payment::STATUS_PENDING
                    : $payment->status,
            ]);
        } else {
            Log::channel('payway')->warning('Webhook for unknown tran_id', ['tran_id' => $tranId]);
        }

        ProcessWebhook::dispatch($tranId, $payload);

        return response('OK', 200);
    }
}
