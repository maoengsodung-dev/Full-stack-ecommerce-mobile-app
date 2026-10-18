<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ProductVariant extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'sku',
        'size',
        'color',
        'price_offset',
        'stock',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'price_offset' => 'decimal:2',
            'is_active'    => 'boolean',
            'stock'        => 'integer',
        ];
    }

    protected $touches = ['product'];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function images(): HasMany
    {
        return $this->hasMany(ProductImage::class);
    }

    public function effectivePrice(): float
    {
        $base = $this->product?->effective_price ?? 0;
        return round((float) $base + (float) $this->price_offset, 2);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
