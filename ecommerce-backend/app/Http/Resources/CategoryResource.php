<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'name'           => $this->name,
            'slug'           => $this->slug,
            'description'    => $this->description,
            'icon'           => $this->formatUrl($this->icon),
            'image'          => $this->formatUrl($this->image),
            'parent_id'      => $this->parent_id,
            'sort_order'     => $this->sort_order,
            'is_active'      => (bool) $this->is_active,
            'products'       => ProductResource::collection($this->whenLoaded('products')),
            'children'       => CategoryResource::collection($this->whenLoaded('children')),
            'products_count' => $this->products_count ?? ($this->relationLoaded('products') ? $this->products->count() : ($this->whenCounted('products') ?? 0)),
        ];
    }

    private function formatUrl(?string $url): ?string
    {
        if (empty($url)) {
            return null;
        }

        if (Str::startsWith($url, ['http://', 'https://'])) {
            return $url;
        }

        return Storage::disk('public')->url(ltrim($url, '/'));
    }
}
