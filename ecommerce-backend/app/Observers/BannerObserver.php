<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Banner;
use Illuminate\Support\Facades\Cache;

class BannerObserver
{
    public function saved(Banner $banner): void
    {
        $this->clearCache($banner);
    }

    public function deleted(Banner $banner): void
    {
        $this->clearCache($banner);
    }

    public function restored(Banner $banner): void
    {
        $this->clearCache($banner);
    }

    public function forceDeleted(Banner $banner): void
    {
        $this->clearCache($banner);
    }

    private function clearCache(Banner $banner): void
    {
        Cache::forget('banners:active:json');
        Cache::forget('banners:active:all');
        Cache::forget("banners:active:pos:{$banner->position}");
    }
}
