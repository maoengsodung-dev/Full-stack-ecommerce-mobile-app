<?php

declare(strict_types=1);

namespace App\Listeners;

use App\Events\OrderStatusChanged;
use App\Events\OrderShipped;
use App\Jobs\SendFCMNotification;
use App\Jobs\SendOrderEmail;
use App\Models\Order;

class SendOrderStatusNotification
{
    public function handleOrderStatusChanged(OrderStatusChanged $event): void
    {
        $order = $event->order;

        SendFCMNotification::dispatch(
            target: ['type' => 'user', 'value' => $order->user_id],
            title: $this->titleFor($order),
            body:  $this->bodyFor($order),
            data:  [
                'event'        => 'order.status_changed',
                'order_id'     => $order->id,
                'order_number' => $order->order_number,
                'status'       => $order->status,
            ],
        );

        SendOrderEmail::dispatch($order, $order->status);

        if ($order->status === Order::STATUS_SHIPPED) {
            event(new OrderShipped($order));
        }
    }

    public function handleOrderShipped(OrderShipped $event): void
    {
        $order = $event->order;
        SendFCMNotification::dispatch(
            target: ['type' => 'user', 'value' => $order->user_id],
            title: 'Your order has shipped',
            body:  "Tracking #{$order->tracking_number}",
            data:  [
                'event'           => 'order.shipped',
                'order_id'        => $order->id,
                'order_number'    => $order->order_number,
                'tracking_number' => (string) $order->tracking_number,
            ],
        );
    }

    private function titleFor(Order $order): string
    {
        return match ($order->status) {
            Order::STATUS_PAID       => 'Payment received',
            Order::STATUS_PROCESSING => 'Order being prepared',
            Order::STATUS_SHIPPED    => 'Order shipped',
            Order::STATUS_DELIVERED  => 'Order delivered',
            Order::STATUS_CANCELLED  => 'Order cancelled',
            Order::STATUS_REFUNDED   => 'Order refunded',
            default                  => 'Order update',
        };
    }

    private function bodyFor(Order $order): string
    {
        return "Order {$order->order_number} is now {$order->status}.";
    }
}
