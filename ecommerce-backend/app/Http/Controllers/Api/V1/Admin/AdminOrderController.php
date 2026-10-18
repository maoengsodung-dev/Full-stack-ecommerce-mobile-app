<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\UpdateOrderStatusRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    public function __construct(
        private readonly OrderService $orders
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $query = Order::query()->with(['user', 'items', 'latestPayment']);

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }
        if ($paymentStatus = $request->query('payment_status')) {
            $query->where('payment_status', $paymentStatus);
        }
        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search): void {
                $q->where('order_number', 'like', "%{$search}%")
                  ->orWhereHas('user', fn ($u) => $u->where('email', 'like', "%{$search}%"));
            });
        }

        $orders = $query->latest()->paginate((int) $request->query('per_page', 25));

        return $this->ok(OrderResource::collection($orders));
    }

    public function updateStatus(UpdateOrderStatusRequest $request, int $id): JsonResponse
    {
        /** @var Order $order */
        $order = Order::findOrFail($id);
        $data  = $request->validated();

        $order = $this->orders->transitionStatus(
            $order,
            $data['status'],
            $data['tracking_number'] ?? null,
        );

        return $this->ok(
            new OrderResource($order->fresh(['items', 'latestPayment'])),
            'Order status updated.'
        );
    }
}
