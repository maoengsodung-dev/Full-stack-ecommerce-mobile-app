<?php

declare(strict_types=1);

namespace App\Models;

use App\Observers\ProductObserver;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

#[ObservedBy([ProductObserver::class])]
class Product extends Model
{
    use HasFactory;
    use SoftDeletes;

    public const STATUS_DRAFT    = 'draft';
    public const STATUS_ACTIVE   = 'active';
    public const STATUS_INACTIVE = 'inactive';
    public const STATUS_ARCHIVED = 'archived';

    protected $fillable = [
        'name',
        'slug',
        'description',
        'short_description',
        'price',
        'sale_price',
        'stock',
        'category_id',
        'status',
        'is_featured',
        'rating',
        'reviews_count',
        'sold_count',
        'attributes',
    ];

    protected function casts(): array
    {
        return [
            'price'         => 'decimal:2',
            'sale_price'    => 'decimal:2',
            'rating'        => 'decimal:2',
            'is_featured'   => 'boolean',
            'attributes'    => 'array',
            'stock'         => 'integer',
            'reviews_count' => 'integer',
            'sold_count'    => 'integer',
        ];
    }

    public function getRouteKeyName(): string
    {
        return 'slug';
    }

    protected static function booted(): void
    {
        static::saving(function (self $product): void {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name).'-'.Str::random(6);
            }
        });
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function variants(): HasMany
    {
        return $this->hasMany(ProductVariant::class);
    }

    public function activeVariants(): HasMany
    {
        return $this->hasMany(ProductVariant::class)->where('is_active', true);
    }

    public function images(): HasMany
    {
        return $this->hasMany(ProductImage::class)->orderBy('sort_order');
    }

    public function primaryImage(): HasOne
    {
        return $this->hasOne(ProductImage::class)->where('is_primary', true);
    }

    public function wishedBy(): HasMany
    {
        return $this->hasMany(Wishlist::class);
    }

    public function getEffectivePriceAttribute(): float
    {
        return (float) ($this->sale_price ?? $this->price);
    }

    public function getOnSaleAttribute(): bool
    {
        return ! is_null($this->sale_price) && (float) $this->sale_price < (float) $this->price;
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    public function scopeFeatured(Builder $query): Builder
    {
        return $query->where('is_featured', true);
    }

    public function scopeInStock(Builder $query): Builder
    {
        return $query->where('stock', '>', 0);
    }

    public function scopeSearch(Builder $query, ?string $term): Builder
    {
        if (blank($term)) {
            return $query;
        }

        $term = trim($term);

        // Fast path: use MySQL native Full-Text index if on MySQL and term is 3+ characters
        if (DB::connection()->getDriverName() === 'mysql' && strlen($term) >= 3) {
            return $query->whereFullText(['name', 'description', 'short_description'], $term.'*', ['mode' => 'boolean']);
        }

        $like = '%'.$term.'%';

        return $query->where(function (Builder $q) use ($like): void {
            $q->where('name', 'like', $like)
              ->orWhere('short_description', 'like', $like)
              ->orWhere('description', 'like', $like);
        });
    }

    public function scopeFilter(Builder $query, array $filters): Builder
    {
        return $query
            ->when($filters['category_id'] ?? null,
                fn (Builder $q, $id) => $q->where('category_id', $id))
            ->when($filters['category'] ?? null, function (Builder $q, string $slug): void {
                $categoryId = Cache::remember(
                    "category:slug_to_id:{$slug}",
                    86400,
                    fn () => Category::where('slug', $slug)->value('id')
                );

                if ($categoryId) {
                    $q->where('category_id', $categoryId);
                } else {
                    $q->whereRaw('0 = 1');
                }
            })
            ->when($filters['min_price'] ?? null,
                fn (Builder $q, $min) => $q->where('price', '>=', $min))
            ->when($filters['max_price'] ?? null,
                fn (Builder $q, $max) => $q->where('price', '<=', $max))
            ->when($filters['featured'] ?? null,
                fn (Builder $q) => $q->featured())
            ->when($filters['in_stock'] ?? null,
                fn (Builder $q) => $q->inStock())
            ->when($filters['search'] ?? null,
                fn (Builder $q, $term) => $q->search($term));
    }
}
