<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Support\Facades\Gate;
use Laravel\Horizon\HorizonApplicationServiceProvider;

class HorizonServiceProvider extends HorizonApplicationServiceProvider
{
    public function boot(): void
    {
        parent::boot();
    }

    protected function gate(): void
    {
        Gate::define('viewHorizon', function ($user = null): bool {
            // Allow access in local environment without authentication
            if (app()->environment('local')) {
                return true;
            }

            return $user !== null && method_exists($user, 'hasRole') && $user->hasRole('admin');
        });
    }
}
