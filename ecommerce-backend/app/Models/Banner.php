<?php

declare(strict_types=1);

namespace App\Models;

use App\Observers\BannerObserver;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

#[ObservedBy([BannerObserver::class])]
class Banner extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'title',
        'subtitle',
        'image',
        'link_type',
        'link_id',
        'link_url',
        'position',
        'sort_order',
        'is_active',
        'start_at',
        'end_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active'  => 'boolean',
            'sort_order' => 'integer',
            'start_at'   => 'datetime',
            'end_at'     => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::deleted(function (self $banner): void {
            if ($banner->isForceDeleting() && $banner->image && ! str_starts_with($banner->image, 'http://') && ! str_starts_with($banner->image, 'https://')) {
                Storage::disk('public')->delete($banner->image);
            }
        });
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true)
            ->where(function (Builder $q): void {
                $q->whereNull('start_at')
                    ->orWhere('start_at', '<=', now());
            })
            ->where(function (Builder $q): void {
                $q->whereNull('end_at')
                    ->orWhere('end_at', '>=', now());
            });
    }

    public function scopePosition(Builder $query, string $position): Builder
    {
        return $query->where('position', $position);
    }
}
