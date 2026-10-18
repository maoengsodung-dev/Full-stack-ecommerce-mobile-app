<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Category;
use Illuminate\Support\Facades\Cache;

class CategoryObserver
{
    public function saved(Category $category): void
    {
        $this->clearCache($category);
    }

    public function deleted(Category $category): void
    {
        $this->clearCache($category);
    }

    public function restored(Category $category): void
    {
        $this->clearCache($category);
    }

    public function forceDeleted(Category $category): void
    {
        $this->clearCache($category);
    }

    private function clearCache(Category $category): void
    {
        Cache::forget('categories:tree');
        Cache::forget('categories:tree:json');
        Cache::forget('categories:roots');
        Cache::forget('categories:all');
        Cache::forget("category:slug_to_id:{$category->slug}");
        Cache::forget("category:show:json:{$category->slug}");

        $originalSlug = $category->getOriginal('slug');
        if ($originalSlug && $originalSlug !== $category->slug) {
            Cache::forget("category:slug_to_id:{$originalSlug}");
            Cache::forget("category:show:json:{$originalSlug}");
        }
    }
}
