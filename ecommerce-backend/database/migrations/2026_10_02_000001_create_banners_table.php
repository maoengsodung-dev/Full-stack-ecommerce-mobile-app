<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('banners', function (Blueprint $table): void {
            $table->id();
            $table->string('title')->nullable();
            $table->text('subtitle')->nullable();
            $table->string('image');
            $table->string('link_type')->default('none'); // 'none', 'category', 'product', 'external'
            $table->string('link_id')->nullable(); // category id/slug, product id/slug
            $table->string('link_url', 500)->nullable(); // external or custom URL
            $table->string('position', 50)->default('home_slider'); // 'home_slider', 'promo_top', etc.
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamp('start_at')->nullable();
            $table->timestamp('end_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('banners');
    }
};
