<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Throwable;

class SendOrderEmail implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public int $tries   = 3;
    public int $timeout = 30;

    public function __construct(
        public Order $order,
        public string $status,
    ) {
        $this->onQueue('emails');
    }

    public function backoff(): array
    {
        return [30, 120, 600];
    }

    public function handle(): void
    {
        $order = $this->order->fresh(['user', 'items']);

        if (! $order || ! $order->user || ! $order->user->email) {
            return;
        }

        $subject = "Order {$order->order_number} — {$this->status}";
        $body    = "Hi {$order->user->name},\n\n"
            ."Your order {$order->order_number} is now {$this->status}.\n"
            ."Total: {$order->currency} ".number_format((float) $order->total, 2)."\n\n"
            .'Thank you for shopping with us.';

        try {
            Mail::raw($body, function ($message) use ($order, $subject): void {
                $message->to($order->user->email, $order->user->name)
                        ->subject($subject);
            });
        } catch (Throwable $e) {
            Log::error('SendOrderEmail failed', [
                'order_id' => $order->id,
                'error'    => $e->getMessage(),
            ]);
            throw $e;
        }
    }
}
