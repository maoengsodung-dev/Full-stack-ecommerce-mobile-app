<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;

class RouteServiceProvider extends ServiceProvider
{
    public const HOME = '/';

    public function boot(): void
    {
        // Bootstrap-driven routing already wired in bootstrap/app.php.
        // This provider is kept for explicitness and any future hooks.
    }
}
