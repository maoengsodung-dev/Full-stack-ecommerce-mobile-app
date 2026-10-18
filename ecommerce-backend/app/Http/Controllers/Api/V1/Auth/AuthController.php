<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Spatie\Permission\Models\Role;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();
        $customerRole = Role::firstOrCreate([
            'name'       => 'customer',
            'guard_name' => config('auth.defaults.guard', 'web'),
        ]);

        [$user, $token] = DB::transaction(function () use ($data, $customerRole): array {
            /** @var User $user */
            $user = User::create([
                'name'     => $data['name'],
                'email'    => $data['email'],
                'phone'    => $data['phone'] ?? null,
                'password' => $data['password'],
            ]);
            $user->assignRole($customerRole);

            return [$user, $this->issueToken($user, $data['device_name'] ?? 'api')];
        });

        return $this->created([
            'token' => $token,
            'user'  => new UserResource($user->load('roles')),
        ], 'Registration successful.');
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();

        /** @var User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (! $user->is_active) {
            return $this->error('Your account is inactive.', 403, code: 'ACCOUNT_INACTIVE');
        }

        // Token rotation: each successful login revokes existing tokens for this device name.
        $deviceName = $data['device_name'] ?? 'api';
        $user->tokens()->where('name', $deviceName)->delete();

        $token = $this->issueToken($user, $deviceName);

        return $this->ok([
            'token' => $token,
            'user'  => new UserResource($user->load('roles')),
        ], 'Login successful.');
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return $this->ok(null, 'Logged out.');
    }

    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return $this->ok(new UserResource($user->load('roles')));
    }

    /**
     * Update authenticated user profile and/or upload avatar.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'name'   => ['sometimes', 'nullable', 'string', 'max:255'],
            'email'  => ['sometimes', 'nullable', 'email', 'max:255', 'unique:users,email,' . $user->id],
            'phone'  => ['sometimes', 'nullable', 'string', 'max:50'],
            'avatar' => ['sometimes', 'nullable'],
            'image'  => ['sometimes', 'nullable'],
            'photo'  => ['sometimes', 'nullable'],
        ]);

        $file = $request->file('avatar') ?? $request->file('image') ?? $request->file('photo');

        if ($file) {
            $request->validate([
                'avatar' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp,gif', 'max:5120'],
                'image'  => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp,gif', 'max:5120'],
                'photo'  => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp,gif', 'max:5120'],
            ]);

            // Remove old local avatar if present
            if ($user->avatar && ! str_starts_with($user->avatar, 'http') && Storage::disk('public')->exists($user->avatar)) {
                Storage::disk('public')->delete($user->avatar);
            }

            $path = $file->store('avatars', 'public');
            $validated['avatar'] = $path;
        }

        unset($validated['image'], $validated['photo']);

        $cleanData = array_filter($validated, fn($val) => $val !== null);
        if (! empty($cleanData)) {
            $user->update($cleanData);
        }

        return $this->ok(new UserResource($user->fresh()->load('roles')), 'Profile updated successfully.');
    }

    /**
     * Refresh: revoke the current token and issue a new one (rotation).
     */
    public function refresh(Request $request): JsonResponse
    {
        $user  = $request->user();
        $token = $user->currentAccessToken();
        $name  = $token?->name ?? 'api';

        $token?->delete();
        $newToken = $this->issueToken($user, $name);

        return $this->ok([
            'token' => $newToken,
            'user'  => new UserResource($user->load('roles')),
        ], 'Token refreshed.');
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $status = Password::broker()->sendResetLink($request->only('email'));

        if ($status === Password::RESET_LINK_SENT) {
            return $this->ok(null, 'Password reset link sent. Please check your email.');
        }

        return $this->error('Unable to send password reset link.', 422, code: 'PASSWORD_RESET_FAILED');
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $status = Password::broker()->reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password): void {
                $user->forceFill(['password' => $password])->save();
                $user->tokens()->delete();
            }
        );

        return $status === Password::PASSWORD_RESET
            ? $this->ok(null, 'Password reset successfully.')
            : $this->error('Invalid or expired token.', 422, code: 'PASSWORD_RESET_INVALID');
    }

    private function issueToken(User $user, string $deviceName): string
    {
        $abilities = $user->isAdmin() ? ['admin', '*'] : ['customer'];

        $minutes   = (int) config('sanctum.expiration', 7 * 24 * 60);
        $expiresAt = now()->addMinutes($minutes);

        return $user->createToken($deviceName, $abilities, $expiresAt)->plainTextToken;
    }
}
