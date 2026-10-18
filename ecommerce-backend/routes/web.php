<?php

declare(strict_types=1);

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'name'    => config('app.name'),
        'env'     => config('app.env'),
        'version' => 'v1',
        'docs'    => '/api/v1',
    ]);
});
