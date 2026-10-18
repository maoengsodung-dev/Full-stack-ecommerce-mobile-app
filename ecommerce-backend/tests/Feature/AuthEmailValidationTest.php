<?php

declare(strict_types=1);

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthEmailValidationTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_and_login_work_without_seeded_customer_role(): void
    {
        $email = 'new.customer@mail.test';
        $password = 'Secure123!';

        $this->postJson('/api/v1/auth/register', [
            'name'                  => 'New Customer',
            'email'                 => $email,
            'password'              => $password,
            'password_confirmation' => $password,
        ])->assertCreated();

        $this->assertDatabaseHas('roles', [
            'name'       => 'customer',
            'guard_name' => 'web',
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email'    => $email,
            'password' => $password,
        ])->assertOk();
    }
}
