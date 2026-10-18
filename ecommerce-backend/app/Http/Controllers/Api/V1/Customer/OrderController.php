<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\StoreOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\OrderService;
use App\Services\PayWayService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(
        private readonly OrderService $orders,
        private readonly PayWayService $payway,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $orders = Order::query()
            ->forUser($request->user()->id)
            ->with(['items', 'latestPayment'])
            ->latest()
            ->paginate(20);

        return $this->ok(OrderResource::collection($orders));
    }

    public function show(Request $request, string $orderNumber): JsonResponse
    {
        /** @var Order $order */
        $order = Order::query()
            ->forUser($request->user()->id)
            ->with(['items', 'payments', 'latestPayment'])
            ->where('order_number', $orderNumber)
            ->firstOrFail();

        return $this->ok(new OrderResource($order));
    }

    public function store(StoreOrderRequest $request): JsonResponse
    {
        $data = $request->validated();

        $order = $this->orders->checkoutFromCart(
            user: $request->user(),
            addressId: (int) $data['address_id'],
            note: $data['note'] ?? null,
            paymentMethod: $data['payment_method'] ?? 'payway',
        );

        $payment = null;
        if (($data['payment_method'] ?? 'payway') === 'payway') {
            $payment = $this->payway->initiatePayment(
                $order->fresh(['items', 'user']),
                paymentOption: $data['payment_option'] ?? null,
            );
        }

        return $this->created([
            'order'   => new OrderResource($order->load(['items'])),
            'payment' => $payment !== null ? [
                'gateway'     => 'payway',
                'action_url'  => $payment['action_url'],
                'form_fields' => $payment['form_fields'],
            ] : null,
        ], 'Order placed.');
    }

    public function cancel(Request $request, int $id): JsonResponse
    {
        /** @var Order $order */
        $order = Order::query()
            ->forUser($request->user()->id)
            ->findOrFail($id);

        $order = $this->orders->cancel($order);

        return $this->ok(new OrderResource($order->fresh('items')), 'Order cancelled.');
    }
}
