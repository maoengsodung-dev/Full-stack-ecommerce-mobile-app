<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name'              => 'Admin',
                'password'          => 'Admin123!',
                'phone'             => '+85510000001',
                'is_active'         => true,
                'email_verified_at' => now(),
            ]
        );
        if (! $admin->hasRole('admin')) {
            $admin->assignRole('admin');
        }

        $customer = User::updateOrCreate(
            ['email' => 'customer@example.com'],
            [
                'name'              => 'Demo Customer',
                'password'          => 'Customer123!',
                'phone'             => '+85510000002',
                'is_active'         => true,
                'email_verified_at' => now(),
            ]
        );
        if (! $customer->hasRole('customer')) {
            $customer->assignRole('customer');
        }

        $admin2 = User::updateOrCreate(
            ['email' => 'admin168168@gmail.com'],
            [
                'name'              => 'Admin',
                'password'          => 'Admin123!',
                'phone'             => '+85510000003',
                'is_active'         => true,
                'email_verified_at' => now(),
            ]
        );
        if (! $admin2->hasRole('admin')) {
            $admin2->assignRole('admin');
        }
    }
}
