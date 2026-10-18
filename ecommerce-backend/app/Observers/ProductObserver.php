<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Product;
use Illuminate\Support\Facades\Cache;

class ProductObserver
{
    public function saved(Product $product): void
    {
        $this->clearCache($product);
    }

    public function deleted(Product $product): void
    {
        $this->clearCache($product);
    }

    public function restored(Product $product): void
    {
        $this->clearCache($product);
    }

    public function forceDeleted(Product $product): void
    {
        $this->clearCache($product);
    }

    private function clearCache(Product $product): void
    {
        Cache::forget("product:slug:{$product->slug}");
        Cache::forget("product:slug:json:{$product->slug}");
        Cache::forget('products:default_page_1');
        Cache::forget('products:featured');
        Cache::forget('categories:tree');
        Cache::forget('categories:tree:json');

        $originalSlug = $product->getOriginal('slug');
        if ($originalSlug && $originalSlug !== $product->slug) {
            Cache::forget("product:slug:{$originalSlug}");
            Cache::forget("product:slug:json:{$originalSlug}");
        }

        if (Cache::has('products:cache_version')) {
            Cache::increment('products:cache_version');
        } else {
            Cache::forever('products:cache_version', 2);
        }
    }
}
