<?php

declare(strict_types=1);

return [
    'default' => env('FIREBASE_PROJECT', 'app'),

    'projects' => [
        'app' => [
            'credentials' => env('FIREBASE_CREDENTIALS', storage_path('app/firebase/firebase_credentials.json')),
            'project_id'  => env('FIREBASE_PROJECT_ID'),

            'auth' => [
                'tenant_id' => env('FIREBASE_AUTH_TENANT_ID'),
            ],

            'messaging' => [
                'http_client_options' => [
                    'proxy'    => env('FIREBASE_HTTP_PROXY'),
                    'timeout'  => 15,
                ],
            ],

            'logging' => [
                'http_log_channel'         => env('FIREBASE_LOG_CHANNEL'),
                'http_debug_log_channel'   => env('FIREBASE_DEBUG_LOG_CHANNEL'),
            ],

            'cache_store' => env('FIREBASE_CACHE_STORE', 'file'),
        ],
    ],
];
