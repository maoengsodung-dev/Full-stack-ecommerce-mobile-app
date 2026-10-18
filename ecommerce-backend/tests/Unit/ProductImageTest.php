<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Http\Resources\ProductImageResource;
use App\Models\ProductImage;
use Illuminate\Http\Request;
use Tests\TestCase;

class ProductImageTest extends TestCase
{
    public function test_product_image_resource_formats_local_storage_path(): void
    {
        $image = new ProductImage([
            'url'        => 'products/wireless-headphones.jpg',
            'alt'        => 'Wireless Headphones',
            'sort_order' => 0,
            'is_primary' => true,
        ]);
        $image->id = 1;

        $resource = new ProductImageResource($image);
        $array = $resource->toArray(new Request());

        $this->assertStringContainsString('/storage/products/wireless-headphones.jpg', $array['url']);
        $this->assertEquals('Wireless Headphones', $array['alt']);
        $this->assertTrue($array['is_primary']);
    }

    public function test_product_image_resource_preserves_external_url(): void
    {
        $image = new ProductImage([
            'url'        => 'https://example.com/images/headphones.jpg',
            'alt'        => 'Wireless Headphones',
            'sort_order' => 0,
            'is_primary' => true,
        ]);
        $image->id = 2;

        $resource = new ProductImageResource($image);
        $array = $resource->toArray(new Request());

        $this->assertEquals('https://example.com/images/headphones.jpg', $array['url']);
    }

    public function test_sample_product_image_files_exist(): void
    {
        $files = [
            'wireless-headphones.jpg',
            'smart-watch-pro.png',
            'cotton-t-shirt.jpg',
            'leather-sneakers.jpg',
            'ceramic-mug-set.png',
            'hydrating-face-cream.jpg',
            'running-shorts.png',
        ];

        foreach ($files as $file) {
            $path = storage_path('app/public/products/' . $file);
            $this->assertFileExists($path, "Sample product image file {$file} should exist.");
        }
    }
}
