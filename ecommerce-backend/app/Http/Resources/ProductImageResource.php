<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ProductImageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'url'        => $this->formatUrl($this->url),
            'alt'        => $this->alt,
            'sort_order' => $this->sort_order,
            'is_primary' => (bool) $this->is_primary,
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
