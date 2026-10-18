<?php

declare(strict_types=1);

use App\Http\Middleware\EnsureWebhookFromTrustedIp;
use App\Http\Middleware\ForceJsonResponse;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        apiPrefix: 'api',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Sanctum: process stateful (cookie) requests for SPAs.
        $middleware->statefulApi();

        $middleware->api(prepend: [
            ForceJsonResponse::class,
        ]);

        $middleware->alias([
            'role'             => Spatie\Permission\Middleware\RoleMiddleware::class,
            'permission'       => Spatie\Permission\Middleware\PermissionMiddleware::class,
            'role_or_permission' => Spatie\Permission\Middleware\RoleOrPermissionMiddleware::class,
            'webhook.trusted'  => EnsureWebhookFromTrustedIp::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (Throwable $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return App\Exceptions\ApiExceptionRenderer::render($e, $request);
            }

            return null;
        });
    })
    ->create();
