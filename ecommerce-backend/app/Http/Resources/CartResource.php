<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'subtotal'     => (float) $this->subtotal,
            'discount'     => (float) $this->discount,
            'total'        => (float) $this->total,
            'coupon_code'  => $this->coupon_code,
            'items_count'  => $this->whenLoaded('items', fn () => $this->items->count(), 0),
            'items'        => CartItemResource::collection($this->whenLoaded('items')),
            'updated_at'   => $this->updated_at?->toIso8601String(),
        ];
    }
}
