<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductVariantResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'sku'             => $this->sku,
            'size'            => $this->size,
            'color'           => $this->color,
            'price_offset'    => (float) $this->price_offset,
            'effective_price' => $this->effectivePrice(),
            'stock'           => $this->stock,
            'is_active'       => (bool) $this->is_active,
        ];
    }
}
