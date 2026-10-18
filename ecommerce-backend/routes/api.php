<?php

declare(strict_types=1);

use App\Http\Controllers\Api\V1\Admin\AdminBannerController;
use App\Http\Controllers\Api\V1\Admin\AdminCategoryController;
use App\Http\Controllers\Api\V1\Admin\AdminOrderController;
use App\Http\Controllers\Api\V1\Admin\AdminProductController;
use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Auth\DeviceTokenController;
use App\Http\Controllers\Api\V1\Customer\AddressController;
use App\Http\Controllers\Api\V1\Customer\BannerController;
use App\Http\Controllers\Api\V1\Customer\CartController;
use App\Http\Controllers\Api\V1\Customer\CategoryController;
use App\Http\Controllers\Api\V1\Customer\NotificationController;
use App\Http\Controllers\Api\V1\Customer\OrderController;
use App\Http\Controllers\Api\V1\Customer\ProductController;
use App\Http\Controllers\Api\V1\Customer\WishlistController;
use App\Http\Controllers\Api\V1\Payment\PayWayWebhookController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    /*
     | -----------------------------------------------------------
     | Public catalog
     | -----------------------------------------------------------
     */
    Route::get('products',          [ProductController::class, 'index']);
    Route::get('products/{slug}',   [ProductController::class, 'show']);
    Route::get('categories',        [CategoryController::class, 'index']);
    Route::get('categories/{slug}', [CategoryController::class, 'show']);
    Route::get('banners',           [BannerController::class, 'index']);
    Route::get('banners/{id}',      [BannerController::class, 'show'])->whereNumber('id');
    Route::get('notifications',     [NotificationController::class, 'index']);

    /*
     | -----------------------------------------------------------
     | Authentication
     | -----------------------------------------------------------
     */
    Route::prefix('auth')->group(function (): void {
        Route::post('register',         [AuthController::class, 'register']);
        Route::post('login',            [AuthController::class, 'login'])->middleware('throttle:login');
        Route::post('forgot-password',  [AuthController::class, 'forgotPassword'])->middleware('throttle:forgot-password');
        Route::post('reset-password',   [AuthController::class, 'resetPassword']);

        Route::middleware('auth:sanctum')->group(function (): void {
            Route::get('me',                                  [AuthController::class, 'me']);
            Route::match(['put', 'patch', 'post'], 'me',      [AuthController::class, 'updateProfile']);
            Route::match(['put', 'patch', 'post'], 'profile', [AuthController::class, 'updateProfile']);
            Route::post('me/avatar',                          [AuthController::class, 'updateProfile']);
            Route::post('logout',                             [AuthController::class, 'logout']);
            Route::post('refresh',                            [AuthController::class, 'refresh']);
        });
    });

    /*
     | -----------------------------------------------------------
     | Authenticated customer endpoints
     | -----------------------------------------------------------
     */
    Route::middleware(['auth:sanctum', 'throttle:api'])->group(function (): void {

        // Cart
        Route::get('cart',                [CartController::class, 'show']);
        Route::post('cart/items',         [CartController::class, 'addItem']);
        Route::patch('cart/items/{item}', [CartController::class, 'updateItem'])->whereNumber('item');
        Route::delete('cart/items/{item}', [CartController::class, 'removeItem'])->whereNumber('item');
        Route::delete('cart',             [CartController::class, 'clear']);

        // Wishlist
        Route::get('wishlist',                [WishlistController::class, 'index']);
        Route::post('wishlist/{product_id}',  [WishlistController::class, 'toggle'])->whereNumber('product_id');

        // Addresses
        Route::get('addresses',                  [AddressController::class, 'index']);
        Route::post('addresses',                 [AddressController::class, 'store']);
        Route::put('addresses/{id}',             [AddressController::class, 'update'])->whereNumber('id');
        Route::delete('addresses/{id}',          [AddressController::class, 'destroy'])->whereNumber('id');
        Route::patch('addresses/{id}/default',   [AddressController::class, 'makeDefault'])->whereNumber('id');

        // Orders (customer)
        Route::get('orders',                       [OrderController::class, 'index']);
        Route::get('orders/{order_number}',        [OrderController::class, 'show']);
        Route::post('orders',                      [OrderController::class, 'store']);
        Route::post('orders/{id}/cancel',          [OrderController::class, 'cancel'])->whereNumber('id');

        // ─── ABA PayWay Endpoints ─────────────────────────────────────────────
        Route::post('payments/payway/create',         [App\Http\Controllers\Api\V1\Payment\PayWayPaymentController::class, 'create']);
        Route::get('payments/payway/status/{tranId}', [App\Http\Controllers\Api\V1\Payment\PayWayPaymentController::class, 'status']);

        // Device tokens
        Route::post('device-tokens',     [DeviceTokenController::class, 'store']);
        Route::delete('device-tokens',   [DeviceTokenController::class, 'destroy']);
    });

    /*
     | -----------------------------------------------------------
     | Admin (role: admin)
     | -----------------------------------------------------------
     */
    Route::prefix('admin')
        ->middleware(['auth:sanctum', 'role:admin', 'throttle:api'])
        ->group(function (): void {
            Route::post('products',                                  [AdminProductController::class, 'store']);
            Route::match(['put', 'patch', 'post'], 'products/{id}', [AdminProductController::class, 'update']);
            Route::delete('products/{id}',                          [AdminProductController::class, 'destroy']);
            Route::post('products/{id}/variants',                   [AdminProductController::class, 'addVariant']);
            Route::post('products/{id}/images',                     [AdminProductController::class, 'addImage']);
            Route::match(['put', 'patch', 'post'], 'products/{id}/images/{image}', [AdminProductController::class, 'updateImage'])->whereNumber('image');
            Route::delete('products/{id}/images/{image}',           [AdminProductController::class, 'deleteImage'])->whereNumber('image');
            Route::match(['put', 'patch', 'post'], 'product-images/{image}', [AdminProductController::class, 'updateImageDirect'])->whereNumber('image');
            Route::delete('product-images/{image}',                 [AdminProductController::class, 'deleteImageDirect'])->whereNumber('image');

            Route::get('categories',                      [AdminCategoryController::class, 'index']);
            Route::get('categories/{id}',                 [AdminCategoryController::class, 'show'])->whereNumber('id');
            Route::post('categories',                     [AdminCategoryController::class, 'store']);
            Route::match(['put', 'patch', 'post'], 'categories/{id}', [AdminCategoryController::class, 'update'])->whereNumber('id');
            Route::delete('categories/{id}',              [AdminCategoryController::class, 'destroy'])->whereNumber('id');
            Route::delete('deleteAllCategories',           [AdminCategoryController::class, 'destroyMultiple']);

            Route::get('banners',                                  [AdminBannerController::class, 'index']);
            Route::get('banners/{id}',                             [AdminBannerController::class, 'show'])->whereNumber('id');
            Route::post('banners',                                 [AdminBannerController::class, 'store']);
            Route::match(['put', 'patch', 'post'], 'banners/{id}', [AdminBannerController::class, 'update'])->whereNumber('id');
            Route::delete('banners/{id}',                          [AdminBannerController::class, 'destroy'])->whereNumber('id');
            Route::delete('deleteAllBanners',                      [AdminBannerController::class, 'destroyMultiple']);

            Route::get('orders',                          [AdminOrderController::class, 'index']);
            Route::patch('orders/{id}/status',            [AdminOrderController::class, 'updateStatus'])->whereNumber('id');
        });

    /*
     | -----------------------------------------------------------
     | Payment webhook (no auth, IP-whitelisted)
     | -----------------------------------------------------------
     */
    Route::post('payments/webhook/payway', PayWayWebhookController::class)
        ->middleware(['webhook.trusted:payway', 'throttle:webhook']);
});
