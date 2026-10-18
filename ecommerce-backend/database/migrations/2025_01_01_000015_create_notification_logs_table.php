<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('notification_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->enum('channel', ['fcm', 'email', 'sms'])->default('fcm')->index();
            $table->enum('target_type', ['user', 'topic', 'token'])->default('user');
            $table->string('target', 191);
            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable();
            $table->json('payload')->nullable();
            $table->json('response')->nullable();
            $table->enum('status', ['queued', 'sent', 'failed'])->default('queued')->index();
            $table->string('error', 500)->nullable();
            $table->string('event', 64)->nullable()->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_logs');
    }
};
