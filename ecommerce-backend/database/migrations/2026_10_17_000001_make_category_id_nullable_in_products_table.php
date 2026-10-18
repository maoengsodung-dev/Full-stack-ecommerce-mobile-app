<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        Schema::table('products', function (Blueprint $table): void {
            // Drop foreign key if it exists
            $table->dropForeign('products_category_id_foreign');
        });

        // Modify column to be nullable
        DB::statement('ALTER TABLE `products` MODIFY `category_id` BIGINT UNSIGNED NULL');

        Schema::table('products', function (Blueprint $table): void {
            $table->foreign('category_id')
                ->references('id')
                ->on('categories')
                ->nullOnDelete()
                ->cascadeOnUpdate();
        });
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        Schema::table('products', function (Blueprint $table): void {
            $table->dropForeign('products_category_id_foreign');
        });

        DB::statement('ALTER TABLE `products` MODIFY `category_id` BIGINT UNSIGNED NOT NULL');

        Schema::table('products', function (Blueprint $table): void {
            $table->foreign('category_id')
                ->references('id')
                ->on('categories')
                ->restrictOnDelete()
                ->cascadeOnUpdate();
        });
    }
};
