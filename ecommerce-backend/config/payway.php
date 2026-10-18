<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| ABA PayWay Configuration
|--------------------------------------------------------------------------
|
| The merchant_id and api_key are issued by ABA. PayWay supports a
| sandbox environment that we use for `local` and `staging`. In
| `production`, the live endpoint is used. The HMAC hash is computed as:
|
|   base64( hash_hmac('sha512', $payload, $api_key, true) )
|
*/

return [

    /*
     | Possible values: sandbox | production
     | When APP_ENV !== 'production' the resolver below forces sandbox so
     | that staging deployments cannot accidentally hit live PayWay.
     */
    'mode' => env('PAYWAY_MODE', env('APP_ENV') === 'production' ? 'production' : 'sandbox'),

    'merchant_id' => env('PAYWAY_MERCHANT_ID'),
    'api_key'     => env('PAYWAY_API_KEY'),

    /*
     | The currency the merchant profile accepts at PayWay. ABA only allows
     | currencies that were activated on your merchant profile (typically
     | USD or KHR — sometimes only one of them). The application stores
     | orders in USD and converts to this currency at the PayWay boundary.
     */
    'currency'      => env('PAYWAY_CURRENCY', 'KHR'),
    'view_type'     => env('PAYWAY_VIEW_TYPE', 'hosted_view'),

    /*
     | Default PayWay UI flow when the client request does not specify a
     | `payment_option`. Allowed values:
     |   - cards                  Cards-only hosted page (HTML).
     |   - abapay_khqr            KHQR only (JSON envelope, no deeplink).
     |   - abapay_khqr_deeplink   KHQR + ABA Mobile deeplink (JSON envelope). Default.
     |   - abapay_deeplink        ABA Mobile deeplink only (no QR card).
     |   - alipay | wechat | google_pay
     |   - ''                     Full hosted checkout (cards + KHQR + ABA tabs, HTML).
     | The mobile app may override this per checkout via the order request.
     */
    'payment_option' => env('PAYWAY_PAYMENT_OPTION', 'abapay_khqr_deeplink'),

    /*
     | USD → KHR conversion rate used when the order is in USD but the
     | PayWay merchant only accepts KHR. Set this to whatever rate you
     | display to customers (ABA usually uses 4100 KHR/USD; check your
     | merchant agreement). Only used for outgoing PayWay requests; the
     | application's books continue to record orders in their native
     | currency.
     */
    'usd_to_khr_rate' => (int) env('PAYWAY_USD_TO_KHR_RATE', 4100),

    'endpoints' => [
        'sandbox' => [
            'base_url'    => env('PAYWAY_SANDBOX_BASE_URL', 'https://checkout-sandbox.payway.com.kh'),
            'purchase'    => '/api/payment-gateway/v1/payments/purchase',
        ],
        'production' => [
            'base_url'    => env('PAYWAY_PRODUCTION_BASE_URL', 'https://checkout.payway.com.kh'),
            'purchase'    => '/api/payment-gateway/v1/payments/purchase',
        ],
    ],

    'urls' => [
        'return'           => env('PAYWAY_RETURN_URL'),
        'cancel'           => env('PAYWAY_CANCEL_URL'),
        'continue_success' => env('PAYWAY_CONTINUE_SUCCESS_URL'),
        'return_params'    => env('PAYWAY_RETURN_PARAMS', ''),
    ],

    /*
     | Comma separated list of trusted IPs allowed to hit the webhook.
     | When empty, the middleware allows any IP (use only in local).
     */
    'webhook_ips' => array_filter(array_map('trim', explode(',', (string) env('PAYWAY_WEBHOOK_IPS', '')))),

    'http' => [
        'timeout'         => 15,
        'connect_timeout' => 10,
    ],
];
