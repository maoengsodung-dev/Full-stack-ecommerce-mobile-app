<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $avatarUrl = null;
        if ($this->avatar) {
            $avatarUrl = str_starts_with($this->avatar, 'http')
                ? $this->avatar
                : asset('storage/' . ltrim($this->avatar, '/'));
        }

        return [
            'id'                => $this->id,
            'name'              => $this->name,
            'email'             => $this->email,
            'phone'             => $this->phone,
            'avatar_url'        => $avatarUrl,
            'avatar'            => $avatarUrl,
            'is_active'         => (bool) $this->is_active,
            'roles'             => $this->resource instanceof User
                ? $this->resource->getRoleNames()->values()
                : [],
            'email_verified_at' => $this->email_verified_at?->toIso8601String(),
            'created_at'        => $this->created_at?->toIso8601String(),
        ];
    }
}
