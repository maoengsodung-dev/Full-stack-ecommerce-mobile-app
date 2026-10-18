<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Laravel\Sanctum\Sanctum;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AdminCategoryManagementTest extends TestCase
{
    use DatabaseTransactions;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'customer', 'guard_name' => 'web']);

        $this->admin = User::create([
            'name'     => 'Admin User',
            'email'    => 'admin_cat@test.com',
            'password' => bcrypt('password123'),
        ]);
        $this->admin->assignRole('admin');

        Sanctum::actingAs($this->admin, ['*']);
    }

    public function test_admin_can_create_category(): void
    {
        $response = $this->postJson('/api/v1/admin/categories', [
            'name' => 'Accessories',
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('categories', [
            'name' => 'Accessories',
            'slug' => 'accessories',
        ]);
    }

    public function test_admin_cannot_create_category_with_duplicate_name(): void
    {
        Category::create([
            'name' => 'Watches',
            'slug' => 'watches',
        ]);

        $response = $this->postJson('/api/v1/admin/categories', [
            'name' => 'Watches',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    public function test_admin_cannot_create_category_with_duplicate_slug(): void
    {
        Category::create([
            'name' => 'Smart Watches',
            'slug' => 'watches',
        ]);

        $response = $this->postJson('/api/v1/admin/categories', [
            'name' => 'Analog Watches',
            'slug' => 'watches',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['slug']);
    }

    public function test_deleting_category_permanently_removes_it_from_database(): void
    {
        $category = Category::create([
            'name' => 'Temporary Category',
            'slug' => 'temporary-category',
        ]);

        $response = $this->deleteJson("/api/v1/admin/categories/{$category->id}");

        $response->assertOk();
        $this->assertDatabaseMissing('categories', [
            'id' => $category->id,
        ]);
    }

    public function test_admin_can_recreate_category_with_same_name_after_deletion(): void
    {
        $category = Category::create([
            'name' => 'Hats',
            'slug' => 'hats',
        ]);

        $deleteResponse = $this->deleteJson("/api/v1/admin/categories/{$category->id}");
        $deleteResponse->assertOk();

        $this->assertDatabaseMissing('categories', [
            'id' => $category->id,
        ]);

        $recreateResponse = $this->postJson('/api/v1/admin/categories', [
            'name' => 'Hats',
        ]);

        $recreateResponse->assertCreated();
        $this->assertDatabaseHas('categories', [
            'name' => 'Hats',
            'slug' => 'hats',
        ]);
    }
}
