<?php

declare(strict_types=1);

namespace App\Listeners;

use App\Events\PaymentConfirmed;
use App\Jobs\SendFCMNotification;

class SendPaymentConfirmedNotification
{
    public function handle(PaymentConfirmed $event): void
    {
        $order = $event->order;

        SendFCMNotification::dispatch(
            target: ['type' => 'user', 'value' => $order->user_id],
            title: 'Payment confirmed',
            body:  "We have received your payment for {$order->order_number}.",
            data:  [
                'event'        => 'payment.confirmed',
                'order_id'     => $order->id,
                'order_number' => $order->order_number,
                'amount'       => (string) $order->total,
            ],
        );
    }
}
