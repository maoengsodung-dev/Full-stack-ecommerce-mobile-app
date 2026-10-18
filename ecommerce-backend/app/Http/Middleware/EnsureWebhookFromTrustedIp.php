<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Services\PayWayService;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureWebhookFromTrustedIp
{
    public function handle(Request $request, Closure $next, string $gateway = 'payway'): Response
    {
        $allowed = match ($gateway) {
            'payway' => app(PayWayService::class)->trustedIps(),
            default  => [],
        };

        if (empty($allowed)) {
            // No whitelist configured: allow but tag the request so the
            // handler can still log it. Useful for local dev where the IP
            // can change. In production set PAYWAY_WEBHOOK_IPS.
            return $next($request);
        }

        $remote = $request->ip();

        if (! in_array($remote, $allowed, true)) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Webhook source not allowed.',
                'code'    => 'WEBHOOK_IP_FORBIDDEN',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
