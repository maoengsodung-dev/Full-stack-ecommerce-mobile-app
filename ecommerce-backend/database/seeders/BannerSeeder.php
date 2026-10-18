<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Banner;
use Illuminate\Database\Seeder;

class BannerSeeder extends Seeder
{
    public function run(): void
    {
        $banners = [
            [
                'title'      => 'Mega Summer Sale',
                'subtitle'   => 'Up to 50% Off on Latest Smartphones & Tech',
                'image'      => 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=1200&q=80',
                'link_type'  => 'category',
                'link_id'    => '15',
                'link_url'   => null,
                'position'   => 'home_slider',
                'sort_order' => 1,
                'is_active'  => true,
            ],
            [
                'title'      => 'New Flagship Devices',
                'subtitle'   => 'Experience Next-Gen AI Performance with Galaxy S24 Ultra',
                'image'      => 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=80',
                'link_type'  => 'product',
                'link_id'    => '22',
                'link_url'   => null,
                'position'   => 'home_slider',
                'sort_order' => 2,
                'is_active'  => true,
            ],
            [
                'title'      => 'Smart Life & Wearables',
                'subtitle'   => 'Elevate Your Fitness with Apple Watch Series 9',
                'image'      => 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=1200&q=80',
                'link_type'  => 'product',
                'link_id'    => '23',
                'link_url'   => null,
                'position'   => 'home_slider',
                'sort_order' => 3,
                'is_active'  => true,
            ],
        ];

        foreach ($banners as $bannerData) {
            Banner::updateOrCreate(
                ['title' => $bannerData['title']],
                $bannerData
            );
        }
    }
}
