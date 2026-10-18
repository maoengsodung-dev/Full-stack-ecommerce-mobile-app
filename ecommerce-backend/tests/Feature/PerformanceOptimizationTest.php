<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class PerformanceOptimizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_categories_endpoint_caches_and_returns_child_categories(): void
    {
        $parent = Category::create([
            'name'       => 'Electronics',
            'slug'       => 'electronics',
            'sort_order' => 1,
            'is_active'  => true,
        ]);

        $child = Category::create([
            'name'       => 'Smartphones',
            'slug'       => 'smartphones',
            'parent_id'  => $parent->id,
            'sort_order' => 1,
            'is_active'  => true,
        ]);

        $this->assertFalse(Cache::has('categories:tree'));

        $response = $this->getJson('/api/v1/categories');
        $response->assertOk();
        $response->assertJsonPath('data.0.name', 'Electronics');
        $response->assertJsonPath('data.0.children.0.name', 'Smartphones');

        $this->assertTrue(Cache::has('categories:tree'));

        // Updating a category should invalidate the cache
        $child->update(['name' => 'Phones & Tablets']);
        $this->assertFalse(Cache::has('categories:tree'));
    }

    public function test_product_detail_endpoint_caches_and_invalidates_on_update(): void
    {
        $category = Category::create([
            'name'       => 'Fashion',
            'slug'       => 'fashion',
            'is_active'  => true,
        ]);

        $product = Product::create([
            'name'        => 'Classic White T-Shirt',
            'slug'        => 'classic-white-t-shirt',
            'price'       => 19.99,
            'stock'       => 50,
            'category_id' => $category->id,
            'status'      => Product::STATUS_ACTIVE,
        ]);

        $cacheKey = "product:slug:{$product->slug}";
        $this->assertFalse(Cache::has($cacheKey));

        $response = $this->getJson("/api/v1/products/{$product->slug}");
        $response->assertOk();
        $response->assertJsonPath('data.name', 'Classic White T-Shirt');
        $this->assertTrue(Cache::has($cacheKey));

        // Touching or updating product variant or image invalidates cache
        $variant = ProductVariant::create([
            'product_id'   => $product->id,
            'sku'          => 'TSHIRT-WHT-L',
            'size'         => 'L',
            'color'        => 'White',
            'price_offset' => 2.00,
            'stock'        => 20,
            'is_active'    => true,
        ]);

        $this->assertFalse(Cache::has($cacheKey));
    }

    public function test_filter_by_category_slug_uses_cached_slug_to_id_resolution(): void
    {
        $category = Category::create([
            'name'       => 'Books',
            'slug'       => 'books',
            'is_active'  => true,
        ]);

        $product = Product::create([
            'name'        => 'Laravel High Performance Guide',
            'slug'        => 'laravel-perf-guide',
            'price'       => 29.99,
            'stock'       => 100,
            'category_id' => $category->id,
            'status'      => Product::STATUS_ACTIVE,
        ]);

        $this->assertFalse(Cache::has("category:slug_to_id:books"));

        $response = $this->getJson('/api/v1/products?category=books');
        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.name', 'Laravel High Performance Guide');

        $this->assertTrue(Cache::has("category:slug_to_id:books"));
    }

    public function test_product_search_functions_properly(): void
    {
        $category = Category::create([
            'name'       => 'Gadgets',
            'slug'       => 'gadgets',
            'is_active'  => true,
        ]);

        Product::create([
            'name'              => 'Wireless Noise Cancelling Headphones',
            'slug'              => 'wireless-headphones',
            'short_description' => 'Over-ear Bluetooth headphones with active noise cancellation.',
            'price'             => 149.99,
            'stock'             => 15,
            'category_id'       => $category->id,
            'status'            => Product::STATUS_ACTIVE,
        ]);

        $response = $this->getJson('/api/v1/products?search=Noise');
        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.slug', 'wireless-headphones');
    }
}
