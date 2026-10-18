<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->string('gateway', 32)->default('payway');
            $table->string('tran_id', 64)->unique();
            $table->string('reference', 191)->nullable();
            $table->decimal('amount', 12, 2);
            $table->string('currency', 3)->default('USD');

            $table->enum('status', ['initiated', 'pending', 'succeeded', 'failed', 'cancelled', 'refunded'])
                ->default('initiated')
                ->index();

            $table->json('payload')->nullable();
            $table->json('webhook_response')->nullable();
            $table->string('failure_reason', 191)->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->index(['order_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
