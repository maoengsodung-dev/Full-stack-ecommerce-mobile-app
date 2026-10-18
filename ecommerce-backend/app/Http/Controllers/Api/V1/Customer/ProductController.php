<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class ProductController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $perPage = min((int) $request->query('per_page', 20), 100);
        $sort    = (string) $request->query('sort', '-created_at');
        $page    = (int) $request->query('page', 1);

        $filters = array_filter([
            'category_id' => $request->query('category_id'),
            'category'    => $request->filled('category') ? $request->query('category') : null,
            'min_price'   => $request->filled('min_price') ? $request->query('min_price') : null,
            'max_price'   => $request->filled('max_price') ? $request->query('max_price') : null,
            'featured'    => $request->has('featured') && $request->boolean('featured') ? true : null,
            'in_stock'    => $request->has('in_stock') && $request->boolean('in_stock') ? true : null,
            'search'      => $request->filled('search') ? trim((string) $request->query('search')) : null,
        ], fn ($val) => ! is_null($val));

        $version = Cache::get('products:cache_version', 1);
        $cacheKey = "products:v{$version}:" . md5(json_encode([
            'page'     => $page,
            'per_page' => $perPage,
            'sort'     => $sort,
            'filters'  => $filters,
        ]));

        $payload = Cache::remember($cacheKey, 300, function () use ($perPage, $sort, $filters, $request) {
            $query = Product::query()
                ->active()
                ->with(['category', 'primaryImage'])
                ->filter($filters);

            $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
            $column    = ltrim($sort, '-');
            if (in_array($column, ['created_at', 'price', 'name', 'rating', 'sold_count'], true)) {
                $query->orderBy($column, $direction);
            }

            $paginator = $query->paginate($perPage)->appends($request->query());
            $resourceArr = ProductResource::collection($paginator)->response()->getData(true);

            $result = [
                'success' => true,
                'message' => '',
                'data'    => $resourceArr['data'] ?? [],
            ];

            $meta = $resourceArr['meta'] ?? [];
            if (isset($resourceArr['links'])) {
                $meta['links'] = $resourceArr['links'];
            }
            if (! empty($meta)) {
                $result['meta'] = $meta;
            }

            return $result;
        });

        return response()->json($payload);
    }

    public function show(string $slug): JsonResponse
    {
        $data = Cache::remember("product:slug:json:{$slug}", 3600, function () use ($slug) {
            $product = Product::query()
                ->active()
                ->with(['category', 'images', 'variants' => fn ($q) => $q->where('is_active', true)])
                ->where('slug', $slug)
                ->firstOrFail();

            return (new ProductResource($product))->resolve();
        });

        return $this->ok($data);
    }
}
