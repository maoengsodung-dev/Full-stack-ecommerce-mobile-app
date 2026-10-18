<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table): void {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->longText('description')->nullable();
            $table->text('short_description')->nullable();
            $table->decimal('price', 12, 2);
            $table->decimal('sale_price', 12, 2)->nullable();
            $table->unsignedInteger('stock')->default(0);
            $table->foreignId('category_id')->constrained()->cascadeOnUpdate()->restrictOnDelete();
            $table->enum('status', ['draft', 'active', 'inactive', 'archived'])->default('draft')->index();
            $table->boolean('is_featured')->default(false)->index();
            $table->decimal('rating', 3, 2)->default(0);
            $table->unsignedInteger('reviews_count')->default(0);
            $table->unsignedInteger('sold_count')->default(0);
            $table->json('attributes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            if (DB::connection()->getDriverName() !== 'sqlite') {
                $table->fullText(['name', 'description', 'short_description']);
            }
            $table->index(['status', 'category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
