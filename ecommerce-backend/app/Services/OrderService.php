<?php

declare(strict_types=1);

namespace App\Services;

use App\Events\OrderStatusChanged;
use App\Events\PaymentConfirmed;
use App\Models\Address;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class OrderService
{
    public function __construct(
        private readonly CartService $carts
    ) {
    }

    /**
     * Build an order from the user's current cart and reserve stock.
     */
    public function checkoutFromCart(User $user, int $addressId, ?string $note = null, string $paymentMethod = 'payway'): Order
    {
        return DB::transaction(function () use ($user, $addressId, $note, $paymentMethod): Order {
            $cart = $this->carts->getOrCreate($user);
            $cart->load(['items.product', 'items.variant']);

            if ($cart->items->isEmpty()) {
                throw new RuntimeException('Your cart is empty.');
            }

            /** @var Address $address */
            $address = $user->addresses()->where('id', $addressId)->firstOrFail();

            $order = Order::create([
                'order_number'       => $this->generateOrderNumber(),
                'user_id'            => $user->id,
                'address_id'         => $address->id,
                'shipping_snapshot'  => $address->toSnapshot(),
                'subtotal'           => $cart->subtotal,
                'shipping_fee'       => 0,
                'tax'                => 0,
                'discount'           => $cart->discount,
                'total'              => $cart->total,
                'currency'           => 'USD',
                'status'             => Order::STATUS_PENDING,
                'payment_status'     => Order::PAYMENT_UNPAID,
                'payment_method'     => $paymentMethod,
                'coupon_code'        => $cart->coupon_code,
                'note'               => $note,
            ]);

            foreach ($cart->items as $cartItem) {
                /** @var Product $product */
                $product = Product::query()->lockForUpdate()->findOrFail($cartItem->product_id);
                $variant = null;

                if ($cartItem->product_variant_id) {
                    /** @var ProductVariant $variant */
                    $variant = ProductVariant::query()->lockForUpdate()->findOrFail($cartItem->product_variant_id);
                    if ($variant->stock < $cartItem->quantity) {
                        throw new RuntimeException("Insufficient stock for variant {$variant->sku}.");
                    }
                    $variant->decrement('stock', $cartItem->quantity);
                } else {
                    if ($product->stock < $cartItem->quantity) {
                        throw new RuntimeException("Insufficient stock for {$product->name}.");
                    }
                    $product->decrement('stock', $cartItem->quantity);
                }

                $order->items()->create([
                    'product_id'         => $product->id,
                    'product_variant_id' => $variant?->id,
                    'product_snapshot'   => [
                        'name'  => $product->name,
                        'slug'  => $product->slug,
                        'sku'   => $variant?->sku,
                        'size'  => $variant?->size,
                        'color' => $variant?->color,
                        'image' => $product->primaryImage?->url,
                    ],
                    'quantity'   => $cartItem->quantity,
                    'unit_price' => $cartItem->unit_price,
                    'line_total' => $cartItem->line_total,
                ]);
            }

            $this->carts->clear($user);

            event(new OrderStatusChanged(
                order: $order->fresh('items'),
                previousStatus: null,
                newStatus: Order::STATUS_PENDING,
            ));

            return $order->fresh(['items', 'user']);
        });
    }

    public function generateOrderNumber(): string
    {
        return 'ORD-'.now()->format('Ymd').'-'.strtoupper(Str::random(6));
    }

    /**
     * Transition an order to a new status (admin / system).
     */
    public function transitionStatus(Order $order, string $newStatus, ?string $trackingNumber = null): Order
    {
        return DB::transaction(function () use ($order, $newStatus, $trackingNumber): Order {
            if (! $order->canTransitionTo($newStatus)) {
                throw new UnprocessableEntityHttpException("Cannot transition order from {$order->status} to {$newStatus}.");
            }

            $previous = $order->status;
            $order->status = $newStatus;

            $now = now();
            match ($newStatus) {
                Order::STATUS_PAID       => $order->paid_at      = $order->paid_at      ?? $now,
                Order::STATUS_SHIPPED    => $order->shipped_at   = $order->shipped_at   ?? $now,
                Order::STATUS_DELIVERED  => $order->delivered_at = $order->delivered_at ?? $now,
                Order::STATUS_CANCELLED  => $order->cancelled_at = $order->cancelled_at ?? $now,
                default                  => null,
            };

            if ($newStatus === Order::STATUS_PAID) {
                $order->payment_status = Order::PAYMENT_PAID;
            }
            if ($newStatus === Order::STATUS_DELIVERED && $order->payment_method === 'cod') {
                $order->payment_status = Order::PAYMENT_PAID;
                $order->paid_at        = $order->paid_at ?? $now;
            }
            if ($newStatus === Order::STATUS_REFUNDED) {
                $order->payment_status = Order::PAYMENT_REFUNDED;
            }

            if ($trackingNumber !== null) {
                $order->tracking_number = $trackingNumber;
            }

            if ($newStatus === Order::STATUS_CANCELLED) {
                $this->restoreStock($order);
            }

            $order->save();

            event(new OrderStatusChanged($order, $previous, $newStatus));

            return $order;
        });
    }

    public function cancel(Order $order, string $reason = ''): Order
    {
        if (! $order->isCancellable()) {
            throw new RuntimeException('This order can no longer be cancelled.');
        }

        return $this->transitionStatus($order, Order::STATUS_CANCELLED);
    }

    public function markPaidFromWebhook(Payment $payment, array $webhookResponse): Order
    {
        return DB::transaction(function () use ($payment, $webhookResponse): Order {
            $payment->status           = Payment::STATUS_SUCCEEDED;
            $payment->paid_at          = now();
            $payment->webhook_response = $webhookResponse;
            $payment->save();

            $order = $payment->order()->lockForUpdate()->first();

            if ($order && $order->status === Order::STATUS_PENDING) {
                $previous = $order->status;
                $order->status         = Order::STATUS_PAID;
                $order->payment_status = Order::PAYMENT_PAID;
                $order->paid_at        = now();
                $order->save();

                event(new OrderStatusChanged($order, $previous, Order::STATUS_PAID));
                event(new PaymentConfirmed($order, $payment));
            }

            return $order;
        });
    }

    public function markFailedFromWebhook(Payment $payment, array $webhookResponse, string $reason = ''): Payment
    {
        $payment->status           = Payment::STATUS_FAILED;
        $payment->failure_reason   = $reason ?: ($webhookResponse['status_message'] ?? 'Payment failed');
        $payment->webhook_response = $webhookResponse;
        $payment->save();

        Log::channel('payway')->warning('PayWay payment failed', [
            'payment_id' => $payment->id,
            'order_id'   => $payment->order_id,
            'reason'     => $payment->failure_reason,
        ]);

        return $payment;
    }

    public function markCancelledFromWebhook(Payment $payment, array $webhookResponse): Order
    {
        return DB::transaction(function () use ($payment, $webhookResponse): Order {
            $payment->status           = Payment::STATUS_CANCELLED;
            $payment->webhook_response = $webhookResponse;
            $payment->save();

            $order = $payment->order()->lockForUpdate()->first();

            if ($order && $order->isCancellable()) {
                $this->transitionStatus($order, Order::STATUS_CANCELLED);
            }

            return $order;
        });
    }

    private function restoreStock(Order $order): void
    {
        foreach ($order->items()->with(['product', 'variant'])->get() as $item) {
            if ($item->variant) {
                $item->variant->increment('stock', $item->quantity);
            } else {
                $item->product?->increment('stock', $item->quantity);
            }
        }
    }
}
