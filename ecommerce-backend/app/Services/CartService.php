<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class CartService
{
    public function getOrCreate(User $user): Cart
    {
        return Cart::firstOrCreate(['user_id' => $user->id]);
    }

    public function addItem(User $user, int $productId, ?int $variantId, int $quantity): CartItem
    {
        return DB::transaction(function () use ($user, $productId, $variantId, $quantity): CartItem {
            $cart = $this->getOrCreate($user);

            /** @var Product $product */
            $product = Product::active()->findOrFail($productId);

            $variant = null;
            if ($variantId !== null) {
                /** @var ProductVariant $variant */
                $variant = $product->variants()->where('id', $variantId)->where('is_active', true)->firstOrFail();
            }

            $availableStock = $variant?->stock ?? $product->stock;
            if ($availableStock < $quantity) {
                throw new RuntimeException('Insufficient stock for the requested quantity.');
            }

            $unitPrice = $variant ? $variant->effectivePrice() : $product->effective_price;

            $existing = $cart->items()
                ->where('product_id', $productId)
                ->where('product_variant_id', $variantId)
                ->lockForUpdate()
                ->first();

            if ($existing) {
                $existing->quantity   = $existing->quantity + $quantity;
                $existing->unit_price = $unitPrice;
                $existing->recalculateLineTotal();
                $existing->save();
                $item = $existing;
            } else {
                $item = $cart->items()->create([
                    'product_id'         => $productId,
                    'product_variant_id' => $variantId,
                    'quantity'           => $quantity,
                    'unit_price'         => $unitPrice,
                    'line_total'         => round($unitPrice * $quantity, 2),
                ]);
            }

            $cart->recalculate();

            return $item;
        });
    }

    public function updateItem(User $user, int $itemId, int $quantity): CartItem
    {
        return DB::transaction(function () use ($user, $itemId, $quantity): CartItem {
            $cart = $this->getOrCreate($user);
            /** @var CartItem $item */
            $item = $cart->items()->where('id', $itemId)->lockForUpdate()->firstOrFail();

            $available = $item->variant?->stock ?? $item->product->stock;
            if ($available < $quantity) {
                throw new RuntimeException('Insufficient stock for the requested quantity.');
            }

            $item->quantity = $quantity;
            $item->recalculateLineTotal();
            $item->save();

            $cart->recalculate();

            return $item;
        });
    }

    public function removeItem(User $user, int $itemId): void
    {
        DB::transaction(function () use ($user, $itemId): void {
            $cart = $this->getOrCreate($user);
            $cart->items()->where('id', $itemId)->delete();
            $cart->recalculate();
        });
    }

    public function clear(User $user): Cart
    {
        return DB::transaction(function () use ($user): Cart {
            $cart = $this->getOrCreate($user);
            $cart->items()->delete();
            $cart->discount    = 0;
            $cart->coupon_code = null;
            $cart->subtotal    = 0;
            $cart->total       = 0;
            $cart->save();

            return $cart;
        });
    }
}
