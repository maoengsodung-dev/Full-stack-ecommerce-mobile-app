<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| Firebase Cloud Messaging Configuration
|--------------------------------------------------------------------------
|
| FCM uses the `kreait/laravel-firebase` package. We support a sandbox-style
| `dry_run` flag that does not actually deliver messages and is enabled by
| default for the `local` environment. Service account credentials are
| read from the `FIREBASE_CREDENTIALS` env (JSON file path).
|
*/

return [

    'mode' => env('FCM_MODE', env('APP_ENV') === 'local' ? 'sandbox' : 'production'),

    'dry_run' => filter_var(
        env('FCM_DRY_RUN', env('APP_ENV') === 'local'),
        FILTER_VALIDATE_BOOLEAN
    ),

    'project_id' => env('FIREBASE_PROJECT_ID'),

    'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/firebase/firebase_credentials.json')),

    'default_topic' => env('FCM_DEFAULT_TOPIC', 'promotions'),

    'android' => [
        'priority' => 'high',
        'notification' => [
            'sound'        => 'default',
            'channel_id'   => env('FCM_ANDROID_CHANNEL', 'ecommerce_default'),
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ],
    ],

    'apns' => [
        'headers' => [
            'apns-priority' => '10',
        ],
        'payload' => [
            'aps' => [
                'sound'             => 'default',
                'content-available' => 1,
                'mutable-content'   => 1,
            ],
        ],
    ],

    'invalid_token_errors' => [
        'INVALID_ARGUMENT',
        'UNREGISTERED',
        'NOT_FOUND',
        'INVALID_REGISTRATION',
        'NotRegistered',
        'MismatchSenderId',
        'INVALID_TOKEN',
    ],

    'topics' => [
        'promotions'      => 'promotions',
        'order_updates'   => 'order_updates',
        'new_arrivals'    => 'new_arrivals',
    ],
];
