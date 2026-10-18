<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Cache::remember('categories:tree:json', 86400, function () {
            $productRelations = function ($q) {
                $q->active()->with(['primaryImage', 'images']);
            };

            $tree = Category::query()
                ->active()
                ->roots()
                ->withCount('products')
                ->with([
                    'products' => $productRelations,
                    // 'children' => fn ($q) => $q->active()
                    //     ->withCount('products')
                    //     ->with([
                    //         'products' => $productRelations,
                    //         'children' => fn ($cq) => $cq->active()
                    //             ->withCount('products')
                    //             ->with([
                    //                 'products' => $productRelations,
                    //             ]),
                    //     ])
                    //     ->orderBy('sort_order'),
                ])
                ->orderBy('sort_order')
                ->get();

            return CategoryResource::collection($tree)->resolve();
        });

        return $this->ok($categories);
    }

    public function show(string $slug): JsonResponse
    {
        $data = Cache::remember("category:show:json:{$slug}", 86400, function () use ($slug) {
            $productRelations = function ($q) {
                $q->active()->with(['primaryImage', 'images']);
            };

            $category = Category::query()
                ->active()
                ->where('slug', $slug)
                ->withCount('products')
                ->with([
                    'products' => $productRelations,
                    'children' => fn($q) => $q->active()
                        ->withCount('products')
                        ->with([
                            'products' => $productRelations,
                        ])
                        ->orderBy('sort_order'),
                ])
                ->firstOrFail();

            return (new CategoryResource($category))->resolve();
        });

        return $this->ok($data);
    }
}
