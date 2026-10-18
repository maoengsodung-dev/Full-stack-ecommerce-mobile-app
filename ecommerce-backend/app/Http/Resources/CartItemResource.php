<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CartItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'product_id'         => $this->product_id,
            'product_variant_id' => $this->product_variant_id,
            'quantity'           => $this->quantity,
            'unit_price'         => (float) $this->unit_price,
            'line_total'         => (float) $this->line_total,
            'product'            => new ProductResource($this->whenLoaded('product')),
            'variant'            => new ProductVariantResource($this->whenLoaded('variant')),
        ];
    }
}
