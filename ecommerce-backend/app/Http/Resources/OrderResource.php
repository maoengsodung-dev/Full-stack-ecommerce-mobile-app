<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                => $this->id,
            'order_number'      => $this->order_number,
            'status'            => $this->status,
            'payment_status'    => $this->payment_status,
            'payment_method'    => $this->payment_method,
            'currency'          => $this->currency,
            'subtotal'          => (float) $this->subtotal,
            'shipping_fee'      => (float) $this->shipping_fee,
            'tax'               => (float) $this->tax,
            'discount'          => (float) $this->discount,
            'total'             => (float) $this->total,
            'coupon_code'       => $this->coupon_code,
            'note'              => $this->note,
            'tracking_number'   => $this->tracking_number,
            'shipping_snapshot' => $this->shipping_snapshot,
            'paid_at'           => $this->paid_at?->toIso8601String(),
            'shipped_at'        => $this->shipped_at?->toIso8601String(),
            'delivered_at'      => $this->delivered_at?->toIso8601String(),
            'cancelled_at'      => $this->cancelled_at?->toIso8601String(),
            'items'             => OrderItemResource::collection($this->whenLoaded('items')),
            'latest_payment'    => new PaymentResource($this->whenLoaded('latestPayment')),
            'customer'          => new UserResource($this->whenLoaded('user')),
            'created_at'        => $this->created_at?->toIso8601String(),
        ];
    }
}
