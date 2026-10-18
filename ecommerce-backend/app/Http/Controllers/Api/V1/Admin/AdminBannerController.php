<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBannerRequest;
use App\Http\Requests\UpdateBannerRequest;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class AdminBannerController extends Controller
{
    /**
     * List all banners (for admin dashboard / management).
     */
    public function index(Request $request): JsonResponse
    {
        $banners = Banner::query()
            ->when($request->filled('search'), function ($q) use ($request) {
                $search = $request->query('search');
                $q->where(function ($sub) use ($search) {
                    $sub->where('title', 'like', "%{$search}%")
                        ->orWhere('subtitle', 'like', "%{$search}%");
                });
            })
            ->when($request->has('is_active'), function ($q) use ($request) {
                $q->where('is_active', $request->boolean('is_active'));
            })
            ->when($request->filled('position'), function ($q) use ($request) {
                $q->where('position', $request->query('position'));
            })
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->paginate((int) $request->query('per_page', 20));

        return $this->ok(BannerResource::collection($banners));
    }

    /**
     * Show a single banner by ID.
     */
    public function show(int $id): JsonResponse
    {
        $banner = Banner::findOrFail($id);

        return $this->ok(new BannerResource($banner));
    }

    /**
     * Create a new banner.
     */
    public function store(StoreBannerRequest $request): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('banners/images', 'public');
        }

        $banner = Banner::create($data);

        // Push notification to customers on topic 'all'
        try {
            $title = $banner->title ? "Special Promotion: {$banner->title} 🎉" : 'Special Promotion! 🎉';
            $body = $banner->subtitle ?: 'New discount and exclusive offers are available now. Tap to view!';
            $imageUrl = $banner->image ? (str_starts_with($banner->image, 'http') ? $banner->image : asset('storage/' . $banner->image)) : '';

            \App\Jobs\SendFCMNotification::dispatch(
                target: ['type' => 'topic', 'value' => 'all'],
                title: $title,
                body: $body,
                data: [
                    'event' => 'new_promotion',
                    'type' => 'promo',
                    'id' => (string) $banner->id,
                    'title' => (string) ($banner->title ?? ''),
                    'subtitle' => (string) ($banner->subtitle ?? ''),
                    'link_type' => (string) ($banner->link_type ?? 'none'),
                    'link_id' => (string) ($banner->link_id ?? ''),
                    'link_url' => (string) ($banner->link_url ?? ''),
                    'image' => $imageUrl,
                ],
            );
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::channel('fcm')->error('Failed to dispatch banner promotion notification', ['error' => $e->getMessage()]);
        }

        return $this->created(new BannerResource($banner), 'Banner created successfully.');
    }

    /**
     * Update an existing banner.
     */
    public function update(UpdateBannerRequest $request, int $id): JsonResponse
    {
        /** @var Banner $banner */
        $banner = Banner::findOrFail($id);
        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($banner->image && ! str_starts_with($banner->image, 'http://') && ! str_starts_with($banner->image, 'https://')) {
                Storage::disk('public')->delete($banner->image);
            }
            $data['image'] = $request->file('image')->store('banners/images', 'public');
        }

        $banner->update($data);

        return $this->ok(new BannerResource($banner->fresh()), 'Banner updated successfully.');
    }

    /**
     * Delete a single banner by ID.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        /** @var Banner $banner */
        $banner = Banner::findOrFail($id);

        if ($request->boolean('force')) {
            if ($banner->image && ! str_starts_with($banner->image, 'http://') && ! str_starts_with($banner->image, 'https://')) {
                Storage::disk('public')->delete($banner->image);
            }
            $banner->forceDelete();
        } else {
            $banner->delete();
        }

        return $this->ok(null, 'Banner deleted successfully.');
    }

    /**
     * Delete multiple banners at once.
     */
    public function destroyMultiple(Request $request): JsonResponse
    {
        $request->validate([
            'ids'   => ['required', 'array', 'min:1'],
            'ids.*' => ['integer', 'exists:banners,id'],
        ]);

        $ids = $request->input('ids');
        $banners = Banner::whereIn('id', $ids)->get();

        return DB::transaction(function () use ($request, $banners) {
            foreach ($banners as $banner) {
                if ($request->boolean('force')) {
                    if ($banner->image && ! str_starts_with($banner->image, 'http://') && ! str_starts_with($banner->image, 'https://')) {
                        Storage::disk('public')->delete($banner->image);
                    }
                    $banner->forceDelete();
                } else {
                    $banner->delete();
                }
            }

            return $this->ok(null, count($banners) . ' banners deleted successfully.');
        });
    }
}
