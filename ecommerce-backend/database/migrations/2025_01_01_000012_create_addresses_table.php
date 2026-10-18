<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('addresses', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('label', 32)->nullable();
            $table->string('recipient_name');
            $table->string('phone', 32);
            $table->string('country', 64)->default('Cambodia');
            $table->string('province', 64);
            $table->string('district', 64)->nullable();
            $table->string('commune', 64)->nullable();
            $table->string('address_line_1');
            $table->string('address_line_2')->nullable();
            $table->string('postal_code', 16)->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('is_default')->default(false)->index();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('addresses');
    }
};
