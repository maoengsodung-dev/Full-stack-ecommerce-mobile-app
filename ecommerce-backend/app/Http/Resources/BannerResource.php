<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class BannerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'title'      => $this->title,
            'subtitle'   => $this->subtitle,
            'image'      => $this->formatUrl($this->image),
            'link_type'  => $this->link_type ?? 'none',
            'link_id'    => $this->link_id,
            'link_url'   => $this->link_url,
            'position'   => $this->position ?? 'home_slider',
            'sort_order' => $this->sort_order,
            'is_active'  => (bool) $this->is_active,
            'start_at'   => $this->start_at?->toIso8601String(),
            'end_at'     => $this->end_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
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
