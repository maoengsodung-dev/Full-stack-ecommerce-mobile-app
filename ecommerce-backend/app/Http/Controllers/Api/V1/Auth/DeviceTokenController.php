<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDeviceTokenRequest;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    public function store(StoreDeviceTokenRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = $request->user();

        $deviceToken = DeviceToken::updateOrCreate(
            [
                'user_id' => $user->id,
                'token'   => $data['token'],
            ],
            [
                'platform'    => $data['platform'],
                'device_id'   => $data['device_id']   ?? null,
                'app_version' => $data['app_version'] ?? null,
                'is_active'   => true,
                'last_used_at'=> now(),
            ]
        );

        return $this->ok([
            'id'       => $deviceToken->id,
            'platform' => $deviceToken->platform,
        ], 'Device token registered.');
    }

    public function destroy(Request $request): JsonResponse
    {
        $request->validate([
            'token' => ['required', 'string', 'max:512'],
        ]);

        DeviceToken::where('user_id', $request->user()->id)
            ->where('token', $request->string('token'))
            ->update(['is_active' => false]);

        return $this->ok(null, 'Device token deregistered.');
    }
}
