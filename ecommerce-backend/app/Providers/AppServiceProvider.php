<?php

declare(strict_types=1);

namespace App\Providers;

use App\Services\FCMService;
use App\Services\PayWayService;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Contract\Messaging;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(PayWayService::class, fn () => PayWayService::fromConfig());

        $this->app->singleton(FCMService::class, function ($app): FCMService {
            $messaging = null;
            $credentials = config('firebase.projects.app.credentials');
            if (!empty($credentials) && file_exists($credentials)) {
                try {
                    $messaging = $app->make(Messaging::class);
                } catch (\Throwable $e) {
                    \Illuminate\Support\Facades\Log::channel('fcm')->error('FCM init failed: ' . $e->getMessage());
                }
            }
            return new FCMService($messaging);
        });
    }

    public function boot(): void
    {
        $this->configureRateLimiters();
    }

    private function configureRateLimiters(): void
    {
        RateLimiter::for('api', function (Request $request): Limit {
            return Limit::perMinute((int) env('RATE_LIMIT_API', 60))
                ->by(optional($request->user())->id ?: $request->ip());
        });

        RateLimiter::for('login', function (Request $request): Limit {
            return Limit::perMinute((int) env('RATE_LIMIT_LOGIN', 5))
                ->by((string) $request->input('email').'|'.$request->ip());
        });

        RateLimiter::for('forgot-password', function (Request $request): Limit {
            return Limit::perMinute((int) env('RATE_LIMIT_FORGOT_PASSWORD', 3))
                ->by((string) $request->input('email').'|'.$request->ip());
        });

        RateLimiter::for('webhook', function (Request $request): Limit {
            return Limit::perMinute(120)->by($request->ip());
        });
    }
}
