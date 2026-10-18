<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Cart\AddCartItemRequest;
use App\Http\Requests\Cart\UpdateCartItemRequest;
use App\Http\Resources\CartItemResource;
use App\Http\Resources\CartResource;
use App\Services\CartService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(
        private readonly CartService $carts
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        $cart = $this->carts->getOrCreate($request->user())
            ->load([
                'items.product.primaryImage',
                'items.product.category',
                'items.variant',
            ]);

        return $this->ok(new CartResource($cart));
    }

    public function addItem(AddCartItemRequest $request): JsonResponse
    {
        $data = $request->validated();

        $item = $this->carts->addItem(
            user: $request->user(),
            productId: (int) $data['product_id'],
            variantId: isset($data['product_variant_id']) ? (int) $data['product_variant_id'] : null,
            quantity: (int) $data['quantity'],
        );

        return $this->created(
            new CartItemResource($item->load(['product.primaryImage', 'variant'])),
            'Item added to cart.'
        );
    }

    public function updateItem(UpdateCartItemRequest $request, int $itemId): JsonResponse
    {
        $item = $this->carts->updateItem(
            user: $request->user(),
            itemId: $itemId,
            quantity: (int) $request->validated('quantity'),
        );

        return $this->ok(
            new CartItemResource($item->load(['product.primaryImage', 'variant'])),
            'Cart item updated.'
        );
    }

    public function removeItem(Request $request, int $itemId): JsonResponse
    {
        $this->carts->removeItem($request->user(), $itemId);

        return $this->ok(null, 'Cart item removed.');
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = $this->carts->clear($request->user());

        return $this->ok(new CartResource($cart->fresh('items')), 'Cart cleared.');
    }
}
