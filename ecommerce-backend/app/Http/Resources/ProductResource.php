<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                => $this->id,
            'name'              => $this->name,
            'slug'              => $this->slug,
            'description'       => $this->description,
            'short_description' => $this->short_description,
            'price'             => (float) $this->price,
            'sale_price'        => $this->sale_price !== null ? (float) $this->sale_price : null,
            'effective_price'   => $this->effective_price,
            'on_sale'           => $this->on_sale,
            'stock'             => $this->stock,
            'status'            => $this->status,
            'is_featured'       => (bool) $this->is_featured,
            'rating'            => (float) $this->rating,
            'reviews_count'     => $this->reviews_count,
            'sold_count'        => $this->sold_count,
            'attributes'        => $this->attributes ?? [],
            'category'          => new CategoryResource($this->whenLoaded('category')),
            'images'            => ProductImageResource::collection($this->whenLoaded('images')),
            'primary_image'     => new ProductImageResource($this->whenLoaded('primaryImage')),
            'variants'          => ProductVariantResource::collection($this->whenLoaded('variants')),
            'created_at'        => $this->created_at?->toIso8601String(),
        ];
    }
}
