<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Electronics', 'description' => 'Phones, laptops, audio',   'icon' => 'categories/icons/electronics.png', 'image' => 'categories/images/electronics.jpg'],
            ['name' => 'Fashion',     'description' => 'Clothing & apparel',       'icon' => 'categories/icons/fashion.png',     'image' => 'categories/images/fashion.jpg'],
            ['name' => 'Home',        'description' => 'Living, kitchen & decor',  'icon' => 'categories/icons/home.png',        'image' => 'categories/images/home.jpg'],
            ['name' => 'Beauty',      'description' => 'Skincare & cosmetics',     'icon' => 'categories/icons/beauty.png',      'image' => 'categories/images/beauty.jpg'],
            ['name' => 'Sports',      'description' => 'Gear & athleisure',        'icon' => 'categories/icons/sports.png',      'image' => 'categories/images/sports.jpg'],
        ];

        foreach ($categories as $i => $row) {
            Category::updateOrCreate(
                ['slug' => Str::slug($row['name'])],
                array_merge($row, [
                    'is_active'  => true,
                    'sort_order' => $i,
                ])
            );
        }
    }
}
