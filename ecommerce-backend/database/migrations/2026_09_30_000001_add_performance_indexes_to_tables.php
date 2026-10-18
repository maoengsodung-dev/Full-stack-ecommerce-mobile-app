<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->index(['status', 'created_at'], 'products_status_created_at_idx');
            $table->index(['status', 'is_featured', 'created_at'], 'products_status_featured_created_idx');
            $table->index(['status', 'price'], 'products_status_price_idx');
            $table->index(['status', 'sold_count'], 'products_status_sold_count_idx');
            $table->index(['status', 'rating'], 'products_status_rating_idx');
        });

        Schema::table('product_images', function (Blueprint $table): void {
            $table->index(['product_id', 'is_primary'], 'product_images_product_primary_idx');
        });

        Schema::table('categories', function (Blueprint $table): void {
            $table->index(['parent_id', 'is_active', 'sort_order'], 'categories_parent_active_sort_idx');
        });

        Schema::table('orders', function (Blueprint $table): void {
            $table->index(['user_id', 'created_at'], 'orders_user_created_at_idx');
            $table->index(['status', 'created_at'], 'orders_status_created_at_idx');
        });

        Schema::table('wishlists', function (Blueprint $table): void {
            $table->index(['user_id', 'created_at'], 'wishlists_user_created_at_idx');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->dropIndex('products_status_created_at_idx');
            $table->dropIndex('products_status_featured_created_idx');
            $table->dropIndex('products_status_price_idx');
            $table->dropIndex('products_status_sold_count_idx');
            $table->dropIndex('products_status_rating_idx');
        });

        Schema::table('product_images', function (Blueprint $table): void {
            $table->dropIndex('product_images_product_primary_idx');
        });

        Schema::table('categories', function (Blueprint $table): void {
            $table->dropIndex('categories_parent_active_sort_idx');
        });

        Schema::table('orders', function (Blueprint $table): void {
            $table->dropIndex('orders_user_created_at_idx');
            $table->dropIndex('orders_status_created_at_idx');
        });

        Schema::table('wishlists', function (Blueprint $table): void {
            $table->dropIndex('wishlists_user_created_at_idx');
        });
    }
};
