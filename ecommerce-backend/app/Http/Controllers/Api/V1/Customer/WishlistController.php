<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Resources\WishlistResource;
use App\Models\Product;
use App\Models\Wishlist;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $wishlist = $request->user()
            ->wishlists()
            ->with(['product.primaryImage', 'product.category'])
            ->latest()
            ->paginate(20);

        return $this->ok(WishlistResource::collection($wishlist));
    }

    public function toggle(Request $request, int $productId): JsonResponse
    {
        Product::active()->findOrFail($productId);

        $existing = Wishlist::where('user_id', $request->user()->id)
            ->where('product_id', $productId)
            ->first();

        if ($existing) {
            $existing->delete();
            return $this->ok(['in_wishlist' => false], 'Removed from wishlist.');
        }

        $wishlist = Wishlist::create([
            'user_id'    => $request->user()->id,
            'product_id' => $productId,
        ]);

        return $this->created([
            'in_wishlist' => true,
            'wishlist'    => new WishlistResource($wishlist->load('product.primaryImage')),
        ], 'Added to wishlist.');
    }
}
