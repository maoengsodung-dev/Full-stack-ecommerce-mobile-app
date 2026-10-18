<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Address;
use App\Models\Category;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class RealEcommerceSeeder extends Seeder
{
    public function run(): void
    {
        $fashion = Category::where('slug', 'fashion')->first() ?? Category::create([
            'name' => 'Fashion', 'slug' => 'fashion', 'description' => 'Luxury apparel & outfits',
            'icon' => 'categories/icons/fashion.png', 'image' => 'categories/images/fashion.jpg', 'sort_order' => 1, 'is_active' => true,
        ]);

        $electronics = Category::where('slug', 'electronics')->first() ?? Category::create([
            'name' => 'Electronics', 'slug' => 'electronics', 'description' => 'Gadgets & devices',
            'icon' => 'categories/icons/electronics.png', 'image' => 'categories/images/electronics.jpg', 'sort_order' => 0, 'is_active' => true,
        ]);

        $productsData = [
            [
                'name'              => 'Light Hooded Tracksuit',
                'slug'              => 'light-hooded-tracksuit',
                'category_id'       => $fashion->id,
                'price'             => 1510.80,
                'sale_price'        => 1259.00,
                'image'             => 'products/light-hooded-tracksuit.png',
                'description'       => 'Luxury tailored hooded tracksuit with heavy-knit finish in pale ecru tone. Features ribbed cuffs and ergonomic comfort tailored for cold seasons.',
                'short_description' => 'WinterElegance luxury collection',
                'stock'             => 45,
                'variants'          => [
                    ['size' => 'S', 'color' => 'Pale Ecru', 'sku' => 'TRACKSUIT-ECRU-S', 'offset' => 0],
                    ['size' => 'M', 'color' => 'Pale Ecru', 'sku' => 'TRACKSUIT-ECRU-M', 'offset' => 0],
                    ['size' => 'L', 'color' => 'Pale Ecru', 'sku' => 'TRACKSUIT-ECRU-L', 'offset' => 0],
                ],
            ],
            [
                'name'              => 'Heavy Fleece Hoodie',
                'slug'              => 'heavy-fleece-hoodie',
                'category_id'       => $fashion->id,
                'price'             => 420.00,
                'sale_price'        => null,
                'image'             => 'products/heavy-fleece-hoodie.jpg',
                'description'       => 'Signature heavyweight fleece hoodie built from 500gsm organic French terry cotton. Detailed atelier stitching and premium metal hardware.',
                'short_description' => 'WinterElegance atelier essential',
                'stock'             => 60,
                'variants'          => [
                    ['size' => 'M', 'color' => 'Graphite Black', 'sku' => 'HOODIE-BLK-M', 'offset' => 0],
                    ['size' => 'L', 'color' => 'Graphite Black', 'sku' => 'HOODIE-BLK-L', 'offset' => 0],
                    ['size' => 'XL', 'color' => 'Graphite Black', 'sku' => 'HOODIE-BLK-XL', 'offset' => 0],
                ],
            ],
            [
                'name'              => 'Technical Cargo Joggers',
                'slug'              => 'technical-cargo-joggers',
                'category_id'       => $fashion->id,
                'price'             => 580.00,
                'sale_price'        => null,
                'image'             => 'products/technical-cargo-joggers.png',
                'description'       => 'High-performance technical cargo joggers engineered with water-repellent Japanese ripstop and FIDLOCK magnetic utility pockets.',
                'short_description' => 'WinterElegance performance joggers',
                'stock'             => 35,
                'variants'          => [
                    ['size' => 'S', 'color' => 'Mineral Gray', 'sku' => 'JOGGER-GRY-S', 'offset' => 0],
                    ['size' => 'M', 'color' => 'Mineral Gray', 'sku' => 'JOGGER-GRY-M', 'offset' => 0],
                    ['size' => 'L', 'color' => 'Mineral Gray', 'sku' => 'JOGGER-GRY-L', 'offset' => 0],
                ],
            ],
            [
                'name'              => 'Ribbed Cashmere Beanie',
                'slug'              => 'ribbed-cashmere-beanie',
                'category_id'       => $fashion->id,
                'price'             => 290.00,
                'sale_price'        => null,
                'image'             => 'products/ribbed-cashmere-beanie.png',
                'description'       => '100% Grade-A Mongolian cashmere beanie with a thick ribbed structure providing warmth and softness.',
                'short_description' => 'WinterElegance knitwear',
                'stock'             => 80,
                'variants'          => [
                    ['size' => 'One Size', 'color' => 'Chalk', 'sku' => 'BEANIE-CHK-OS', 'offset' => 0],
                    ['size' => 'One Size', 'color' => 'Black', 'sku' => 'BEANIE-BLK-OS', 'offset' => 0],
                ],
            ],
            [
                'name'              => 'Wireless Headphones',
                'slug'              => 'wireless-headphones-pro',
                'category_id'       => $electronics->id,
                'price'             => 79.00,
                'sale_price'        => 69.00,
                'image'             => 'products/wireless-headphones.jpg',
                'description'       => 'Active noise cancelling wireless headphones with 40-hour battery life and spatial audio.',
                'short_description' => 'Hi-Fi studio sound',
                'stock'             => 100,
                'variants'          => [
                    ['size' => 'Standard', 'color' => 'Matte Black', 'sku' => 'HEADPHONES-BLK', 'offset' => 0],
                ],
            ],
        ];

        $createdProducts = [];

        foreach ($productsData as $data) {
            $product = Product::withTrashed()->firstOrNew(['slug' => $data['slug']]);
            $product->fill([
                'name'              => $data['name'],
                'description'       => $data['description'],
                'short_description' => $data['short_description'],
                'price'             => $data['price'],
                'sale_price'        => $data['sale_price'],
                'stock'             => $data['stock'],
                'category_id'       => $data['category_id'],
                'status'            => Product::STATUS_ACTIVE,
                'is_featured'       => true,
                'rating'            => 5.0,
                'reviews_count'     => 24,
                'sold_count'        => 68,
                'attributes'        => ['origin' => 'Imported', 'warranty' => '2 years'],
            ]);
            if ($product->trashed()) {
                $product->restore();
            }
            $product->save();

            ProductImage::updateOrCreate(
                ['product_id' => $product->id, 'sort_order' => 0],
                [
                    'url'        => $data['image'],
                    'alt'        => $data['name'],
                    'is_primary' => true,
                ]
            );

            $createdVariants = [];
            foreach ($data['variants'] as $v) {
                $variant = ProductVariant::updateOrCreate(
                    ['sku' => $v['sku']],
                    [
                        'product_id'   => $product->id,
                        'size'         => $v['size'],
                        'color'        => $v['color'],
                        'price_offset' => $v['offset'],
                        'stock'        => 30,
                        'is_active'    => true,
                    ]
                );
                $createdVariants[] = $variant;
            }

            $createdProducts[$data['slug']] = [
                'product'  => $product,
                'variants' => $createdVariants,
            ];
        }

        $customer = User::where('email', 'customer@example.com')->first();
        if (! $customer) {
            return;
        }

        $address = Address::firstOrCreate(
            ['user_id' => $customer->id, 'label' => 'Home'],
            [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'country'        => 'Cambodia',
                'province'       => 'Phnom Penh',
                'district'       => 'Chamkarmon',
                'address_line_1' => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
                'is_default'     => true,
            ]
        );

        // Delete previous mock/cancelled duplicate test orders for customer to give a pristine real history
        Order::where('user_id', $customer->id)->forceDelete();

        // ── Order 1: Active In-Transit (#WE-94821) ──────────────────────────────────
        $p1 = $createdProducts['light-hooded-tracksuit']['product'];
        $v1 = $createdProducts['light-hooded-tracksuit']['variants'][1] ?? null; // Size M

        $order1 = Order::create([
            'order_number'    => 'WE-94821',
            'user_id'         => $customer->id,
            'address_id'      => $address->id,
            'shipping_snapshot' => [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'address'        => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
            ],
            'subtotal'        => 1259.00,
            'shipping_fee'    => 0.00,
            'tax'             => 0.00,
            'discount'        => 251.80,
            'total'           => 1259.00,
            'currency'        => 'USD',
            'status'          => Order::STATUS_SHIPPED,
            'payment_status'  => Order::PAYMENT_PAID,
            'payment_method'  => 'payway',
            'tracking_number' => 'TRK-948210-DHL',
            'note'            => 'WinterElegance • Arriving Tomorrow, 2:00 PM',
            'paid_at'         => Carbon::now()->subDay(),
            'shipped_at'      => Carbon::now()->subHours(12),
            'created_at'      => Carbon::now()->subHours(14),
        ]);

        OrderItem::create([
            'order_id'           => $order1->id,
            'product_id'         => $p1->id,
            'product_variant_id' => $v1 ? $v1->id : null,
            'product_snapshot'   => [
                'name'  => $p1->name,
                'slug'  => $p1->slug,
                'image' => 'products/light-hooded-tracksuit.png',
                'sku'   => $v1 ? $v1->sku : 'TRACKSUIT-ECRU-M',
                'size'  => 'M',
                'color' => 'Pale Ecru',
            ],
            'quantity'   => 1,
            'unit_price' => 1259.00,
            'line_total' => 1259.00,
        ]);

        // ── Order 2: Active Processing Atelier (#WE-88310) ─────────────────────────
        $p2 = $createdProducts['heavy-fleece-hoodie']['product'];
        $v2 = $createdProducts['heavy-fleece-hoodie']['variants'][1] ?? null; // Size L

        $order2 = Order::create([
            'order_number'    => 'WE-88310',
            'user_id'         => $customer->id,
            'address_id'      => $address->id,
            'shipping_snapshot' => [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'address'        => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
            ],
            'subtotal'        => 420.00,
            'shipping_fee'    => 0.00,
            'tax'             => 0.00,
            'discount'        => 0.00,
            'total'           => 420.00,
            'currency'        => 'USD',
            'status'          => Order::STATUS_PROCESSING,
            'payment_status'  => Order::PAYMENT_PAID,
            'payment_method'  => 'payway',
            'tracking_number' => null,
            'note'            => 'WinterElegance • Processing Atelier',
            'paid_at'         => Carbon::now()->subHours(4),
            'created_at'      => Carbon::now()->subHours(6),
        ]);

        OrderItem::create([
            'order_id'           => $order2->id,
            'product_id'         => $p2->id,
            'product_variant_id' => $v2 ? $v2->id : null,
            'product_snapshot'   => [
                'name'  => $p2->name,
                'slug'  => $p2->slug,
                'image' => 'products/heavy-fleece-hoodie.jpg',
                'sku'   => $v2 ? $v2->sku : 'HOODIE-BLK-L',
                'size'  => 'L',
                'color' => 'Graphite Black',
            ],
            'quantity'   => 1,
            'unit_price' => 420.00,
            'line_total' => 420.00,
        ]);

        // ── Order 3: Delivered Archives (#WE-76192) ────────────────────────────────
        $p3 = $createdProducts['technical-cargo-joggers']['product'];
        $v3 = $createdProducts['technical-cargo-joggers']['variants'][1] ?? null; // Size M

        $order3 = Order::create([
            'order_number'    => 'WE-76192',
            'user_id'         => $customer->id,
            'address_id'      => $address->id,
            'shipping_snapshot' => [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'address'        => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
            ],
            'subtotal'        => 580.00,
            'shipping_fee'    => 0.00,
            'tax'             => 0.00,
            'discount'        => 0.00,
            'total'           => 580.00,
            'currency'        => 'USD',
            'status'          => Order::STATUS_DELIVERED,
            'payment_status'  => Order::PAYMENT_PAID,
            'payment_method'  => 'payway',
            'tracking_number' => 'TRK-761920-DHL',
            'note'            => 'Courier: DHL Express Concierge • Signed: Residence Desk',
            'paid_at'         => Carbon::now()->subDays(5),
            'shipped_at'      => Carbon::now()->subDays(4),
            'delivered_at'    => Carbon::now()->subDays(3),
            'created_at'      => Carbon::now()->subDays(5),
        ]);

        OrderItem::create([
            'order_id'           => $order3->id,
            'product_id'         => $p3->id,
            'product_variant_id' => $v3 ? $v3->id : null,
            'product_snapshot'   => [
                'name'  => $p3->name,
                'slug'  => $p3->slug,
                'image' => 'products/technical-cargo-joggers.png',
                'sku'   => $v3 ? $v3->sku : 'JOGGER-GRY-M',
                'size'  => 'M',
                'color' => 'Mineral Gray',
            ],
            'quantity'   => 1,
            'unit_price' => 580.00,
            'line_total' => 580.00,
        ]);

        // ── Order 4: Delivered Archives (#WE-65402) ────────────────────────────────
        $p4 = $createdProducts['ribbed-cashmere-beanie']['product'];
        $v4 = $createdProducts['ribbed-cashmere-beanie']['variants'][0] ?? null; // One Size Chalk

        $order4 = Order::create([
            'order_number'    => 'WE-65402',
            'user_id'         => $customer->id,
            'address_id'      => $address->id,
            'shipping_snapshot' => [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'address'        => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
            ],
            'subtotal'        => 290.00,
            'shipping_fee'    => 0.00,
            'tax'             => 0.00,
            'discount'        => 0.00,
            'total'           => 290.00,
            'currency'        => 'USD',
            'status'          => Order::STATUS_DELIVERED,
            'payment_status'  => Order::PAYMENT_PAID,
            'payment_method'  => 'payway',
            'tracking_number' => 'TRK-654020-DHL',
            'note'            => 'Courier: DHL Express Concierge • Signed: Reception',
            'paid_at'         => Carbon::now()->subDays(47),
            'shipped_at'      => Carbon::now()->subDays(46),
            'delivered_at'    => Carbon::now()->subDays(45),
            'created_at'      => Carbon::now()->subDays(47),
        ]);

        OrderItem::create([
            'order_id'           => $order4->id,
            'product_id'         => $p4->id,
            'product_variant_id' => $v4 ? $v4->id : null,
            'product_snapshot'   => [
                'name'  => $p4->name,
                'slug'  => $p4->slug,
                'image' => 'products/ribbed-cashmere-beanie.png',
                'sku'   => $v4 ? $v4->sku : 'BEANIE-CHK-OS',
                'size'  => 'One Size',
                'color' => 'Chalk',
            ],
            'quantity'   => 1,
            'unit_price' => 290.00,
            'line_total' => 290.00,
        ]);

        // ── Order 5: Archived (#ORD-CANCELLED-1) ───────────────────────────────────
        $p5 = $createdProducts['wireless-headphones-pro']['product'];

        $order5 = Order::create([
            'order_number'    => 'ORD-20260907-YCQTGQ',
            'user_id'         => $customer->id,
            'address_id'      => $address->id,
            'shipping_snapshot' => [
                'recipient_name' => 'Demo Customer',
                'phone'          => '012345678',
                'address'        => 'GWR6+7J2, Khan Chamkar Mon, Phnom Penh',
            ],
            'subtotal'        => 69.00,
            'shipping_fee'    => 0.00,
            'tax'             => 0.00,
            'discount'        => 0.00,
            'total'           => 69.00,
            'currency'        => 'USD',
            'status'          => Order::STATUS_CANCELLED,
            'payment_status'  => Order::PAYMENT_UNPAID,
            'payment_method'  => 'payway',
            'tracking_number' => null,
            'note'            => 'Customer cancelled order before fulfillment',
            'cancelled_at'    => Carbon::now()->subDays(24),
            'created_at'      => Carbon::now()->subDays(25),
        ]);

        OrderItem::create([
            'order_id'           => $order5->id,
            'product_id'         => $p5->id,
            'product_variant_id' => null,
            'product_snapshot'   => [
                'name'  => $p5->name,
                'slug'  => $p5->slug,
                'image' => 'products/wireless-headphones.jpg',
            ],
            'quantity'   => 1,
            'unit_price' => 69.00,
            'line_total' => 69.00,
        ]);
    }
}
