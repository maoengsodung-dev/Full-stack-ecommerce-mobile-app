<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Models\NotificationLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user('sanctum');

        $notifications = NotificationLog::query()
            ->where(function ($query) use ($user) {
                $query->where('target_type', 'topic')
                    ->whereIn('target', ['all', 'promotions', 'products', 'general']);

                if ($user !== null) {
                    $query->orWhere(function ($q) use ($user) {
                        $q->where('target_type', 'user')
                          ->where('user_id', $user->id);
                    });
                }
            })
            ->latest('id')
            ->limit(50)
            ->get()
            ->map(function (NotificationLog $log) {
                $type = $log->data['type'] ?? ($log->event === 'new_promotion' ? 'promo' : ($log->event === 'new_product' ? 'product' : 'system'));

                return [
                    'id'         => (string) $log->id,
                    'title'      => $log->title,
                    'body'       => $log->body,
                    'type'       => $type,
                    'data'       => $log->data ?? [],
                    'time'       => $log->created_at?->toISOString() ?? now()->toISOString(),
                    'created_at' => $log->created_at?->toISOString() ?? now()->toISOString(),
                    'is_read'    => false,
                ];
            });

        return $this->ok($notifications);
    }
}
