<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $samples = [
            ['name' => 'Wireless Headphones',  'category' => 'electronics', 'price' => 79.00,  'sale_price' => 69.00, 'image' => 'products/wireless-headphones.jpg'],
            ['name' => 'Smart Watch Pro',      'category' => 'electronics', 'price' => 249.00, 'sale_price' => null,  'image' => 'products/smart-watch-pro.png'],
            ['name' => 'Cotton T-Shirt',       'category' => 'fashion',     'price' => 19.00,  'sale_price' => 14.00, 'image' => 'products/cotton-t-shirt.jpg'],
            ['name' => 'Leather Sneakers',     'category' => 'fashion',     'price' => 89.00,  'sale_price' => null,  'image' => 'products/leather-sneakers.jpg'],
            ['name' => 'Ceramic Mug Set',      'category' => 'home',        'price' => 29.00,  'sale_price' => null,  'image' => 'products/ceramic-mug-set.png'],
            ['name' => 'Hydrating Face Cream', 'category' => 'beauty',      'price' => 39.00,  'sale_price' => 32.00, 'image' => 'products/hydrating-face-cream.jpg'],
            ['name' => 'Running Shorts',       'category' => 'sports',      'price' => 25.00,  'sale_price' => null,  'image' => 'products/running-shorts.png'],
        ];

        foreach ($samples as $s) {
            $category = Category::where('slug', $s['category'])->first();
            if (! $category) {
                continue;
            }

            $product = Product::withTrashed()->firstOrNew(
                ['slug' => Str::slug($s['name']).'-demo']
            );

            $product->fill([
                'name'              => $s['name'],
                'description'       => "Premium quality {$s['name']} for everyday use.",
                'short_description' => "Buy {$s['name']} online with fast shipping.",
                'price'             => $s['price'],
                'sale_price'        => $s['sale_price'],
                'stock'             => 100,
                'category_id'       => $category->id,
                'status'            => Product::STATUS_ACTIVE,
                'is_featured'       => (bool) random_int(0, 1),
                'rating'            => 4.5,
                'reviews_count'     => 12,
                'sold_count'        => 30,
                'attributes'        => ['warranty' => '1 year'],
            ]);

            if ($product->trashed()) {
                $product->restore();
            }

            $product->save();

            ProductImage::updateOrCreate(
                ['product_id' => $product->id, 'sort_order' => 0],
                [
                    'url'        => $s['image'] ?? 'products/'.Str::slug($product->name).'.jpg',
                    'alt'        => $product->name,
                    'is_primary' => true,
                ]
            );

            foreach (['S', 'M', 'L'] as $i => $size) {
                ProductVariant::updateOrCreate(
                    ['sku' => Str::upper(Str::slug($product->name)).'-'.$size],
                    [
                        'product_id'   => $product->id,
                        'size'         => $size,
                        'color'        => 'Black',
                        'price_offset' => $i * 2,
                        'stock'        => 50,
                        'is_active'    => true,
                    ]
                );
            }
        }
    }
}
