<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class BannerController extends Controller
{
    /**
     * Get active banners (optionally filtered by position).
     */
    public function index(Request $request): JsonResponse
    {
        $position = $request->query('position');
        $cacheKey = $position ? "banners:active:pos:{$position}" : 'banners:active:json';

        $banners = Cache::remember($cacheKey, 86400, function () use ($position) {
            $query = Banner::query()
                ->active()
                ->orderBy('sort_order')
                ->orderByDesc('id');

            if ($position) {
                $query->position($position);
            }

            return BannerResource::collection($query->get())->resolve();
        });

        return $this->ok($banners);
    }

    /**
     * Get a single active banner by ID.
     */
    public function show(int $id): JsonResponse
    {
        $banner = Banner::query()
            ->active()
            ->findOrFail($id);

        return $this->ok(new BannerResource($banner));
    }
}
