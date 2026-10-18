<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * ABA PayWay payment gateway integration.
 *
 * Purchase-request hash algorithm (per official ABA PayWay docs at
 * https://developer.payway.com.kh/purchase-14530820e0):
 *   1. Concatenate the payload values in this EXACT positional order
 *      (note: view_type is NOT part of the hash):
 *         req_time, merchant_id, tran_id, amount, items, shipping,
 *         firstname, lastname, email, phone, type, payment_option,
 *         return_url, cancel_url, continue_success_url, return_deeplink,
 *         currency, custom_fields, return_params, payout, lifetime,
 *         additional_params, google_pay_token, skip_success_page
 *      Missing keys are treated as empty strings.
 *   2. hash = base64( hash_hmac('sha512', $beforeHash, $api_key, true) ).
 *
 * Webhook (push-back) signature algorithm (per official PayWay docs):
 *   1. ksort() the decoded JSON request body.
 *   2. Concatenate values; for any array value, json_encode() first.
 *   3. HMAC-SHA512 + base64.
 *   4. Compare with the X-PayWay-HMAC-SHA512 request header (NOT the body).
 */
class PayWayService
{
    public function __construct(
        private readonly array $config
    ) {
    }

    public static function fromConfig(): self
    {
        return new self(config('payway'));
    }

    public function isProduction(): bool
    {
        return ($this->config['mode'] ?? 'sandbox') === 'production';
    }

    public function actionUrl(): string
    {
        $env = $this->isProduction() ? 'production' : 'sandbox';
        $endpoint = $this->config['endpoints'][$env];

        return rtrim($endpoint['base_url'], '/').$endpoint['purchase'];
    }

    /**
     * Build the form fields to POST to PayWay's hosted checkout.
     *
     * The `$paymentOption` argument lets callers (typically the mobile app
     * via the order request) override the default UI flow per checkout:
     * `abapay_khqr_deeplink` for the native KHQR + ABA deeplink response,
     * `cards` / `''` for the HTML hosted page, etc. When `null`, the value
     * configured under `config/payway.php#payment_option` is used.
     *
     * @return array{action_url: string, form_fields: array<string,string>, payment: Payment}
     */
    public function initiatePayment(Order $order, ?string $paymentOption = null): array
    {
        $tranId   = $this->generateTranId($order);
        $reqTime  = Carbon::now('UTC')->format('YmdHis');

        // Convert at the PayWay boundary if the order's native currency does
        // not match what the merchant profile accepts. The application's
        // books continue to record orders in their native currency.
        $orderCurrency  = $order->currency ?: 'USD';
        $payWayCurrency = (string) ($this->config['currency'] ?? $orderCurrency);
        [$multiplier, $decimals] = $this->conversionFactor($orderCurrency, $payWayCurrency);

        $amount   = number_format((float) $order->total * $multiplier, $decimals, '.', '');
        $shipping = number_format((float) $order->shipping_fee * $multiplier, $decimals, '.', '');
        $items    = $this->buildItems($order, $multiplier, $decimals);

        $shippingSnapshot = (array) $order->shipping_snapshot;
        $firstName = (string) ($shippingSnapshot['recipient_name'] ?? $order->user?->name ?? 'Customer');
        $lastName  = '';
        if (str_contains($firstName, ' ')) {
            [$firstName, $lastName] = explode(' ', $firstName, 2);
        }

        // Field order in $payload mirrors PayWay's PURCHASE_HASH_FIELDS so
        // anyone reading the code can see hash inputs and form inputs match.
        // view_type is intentionally placed AFTER the hashable fields because
        // it is NOT part of the hash (per PayWay's spec).
        $payload = [
            'req_time'              => $reqTime,
            'merchant_id'           => (string) ($this->config['merchant_id'] ?? ''),
            'tran_id'               => $tranId,
            'amount'                => $amount,
            'items'                 => $items,
            'shipping'              => $shipping,
            'firstname'             => $firstName,
            'lastname'              => $lastName,
            'email'                 => (string) ($order->user?->email ?? ''),
            'phone'                 => (string) ($shippingSnapshot['phone'] ?? $order->user?->phone ?? ''),
            'type'                  => 'purchase',
            'payment_option'        => $paymentOption ?? (string) ($this->config['payment_option'] ?? ''),
            'return_url'            => (string) ($this->config['urls']['return'] ?? ''),
            'cancel_url'            => (string) ($this->config['urls']['cancel'] ?? ''),
            'continue_success_url'  => (string) ($this->config['urls']['continue_success'] ?? ''),
            'return_deeplink'       => (string) ($this->config['urls']['return_deeplink'] ?? ''),
            'currency'              => $payWayCurrency,
            'custom_fields'         => '',
            'return_params'         => (string) ($this->config['urls']['return_params'] ?? ''),
            'payout'                => '',
            'lifetime'              => '',
            'additional_params'     => '',
            'google_pay_token'      => '',
            'skip_success_page'     => '',
            'view_type'             => (string) ($this->config['view_type'] ?? 'hosted_view'),
        ];

        $hash = $this->generateHash($payload);
        $payload['hash'] = $hash;

        // Payment record stores the order's native currency (USD) so that
        // accounting / dashboards stay consistent with the Order. The exact
        // KHR amount sent to PayWay is preserved in the `payload` JSON.
        $payment = Payment::create([
            'order_id'  => $order->id,
            'gateway'   => 'payway',
            'tran_id'   => $tranId,
            'reference' => $order->order_number,
            'amount'    => $order->total,
            'currency'  => $orderCurrency,
            'status'    => Payment::STATUS_INITIATED,
            'payload'   => $payload,
        ]);

        Log::channel('payway')->info('PayWay payment initiated', [
            'order_id'        => $order->id,
            'tran_id'         => $tranId,
            'order_amount'    => $order->total,
            'order_currency'  => $orderCurrency,
            'payway_amount'   => $amount,
            'payway_currency' => $payWayCurrency,
            'mode'            => $this->config['mode'] ?? 'sandbox',
        ]);

        return [
            'action_url'  => $this->actionUrl(),
            'form_fields' => $payload,
            'payment'     => $payment,
        ];
    }

    /**
     * Resolve the currency-conversion multiplier and decimal precision used
     * when the order currency differs from the PayWay merchant currency.
     *
     * KHR is a no-decimal currency at PayWay (amounts are integers); USD
     * uses two decimals.
     *
     * @return array{0: float, 1: int}  [multiplier, decimals]
     */
    private function conversionFactor(string $orderCurrency, string $payWayCurrency): array
    {
        $decimals = $payWayCurrency === 'KHR' ? 0 : 2;

        if ($orderCurrency === $payWayCurrency) {
            return [1.0, $decimals];
        }

        $rate = (float) ($this->config['usd_to_khr_rate'] ?? 4100);

        return match ([$orderCurrency, $payWayCurrency]) {
            ['USD', 'KHR'] => [$rate, 0],
            ['KHR', 'USD'] => [1.0 / $rate, 2],
            default        => [1.0, $decimals],
        };
    }

    /**
     * Verify the HMAC of an incoming PayWay webhook before doing ANY DB write.
     *
     * Per PayWay's spec, the signature is provided in the
     * X-PayWay-HMAC-SHA512 request header (NOT in the JSON body). The body
     * itself is signed with: ksort, then concatenate values (json_encode
     * any array value), then HMAC-SHA512, then base64.
     *
     * @param  array<string,mixed>  $payload  Decoded JSON request body.
     * @param  string               $providedHash  Value of the X-PayWay-HMAC-SHA512 header.
     */
    public function verifyWebhookSignature(array $payload, string $providedHash): bool
    {
        if ($providedHash === '') {
            return false;
        }

        $expected = $this->buildWebhookHash($payload);

        return hash_equals($expected, $providedHash);
    }

    /**
     * Build the PayWay webhook signature for the given decoded body.
     *
     * Algorithm per https://developer.payway.com.kh/ecommerce-checkout-3158159f0
     * "Verify Callback Signature" section.
     */
    private function buildWebhookHash(array $payload): string
    {
        ksort($payload);

        $beforeHash = '';
        foreach ($payload as $value) {
            if (is_array($value)) {
                $value = json_encode($value, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            }
            $beforeHash .= (string) $value;
        }

        return base64_encode(hash_hmac(
            'sha512',
            $beforeHash,
            (string) ($this->config['api_key'] ?? ''),
            true,
        ));
    }

    /**
     * Map the gateway status_code → app payment status & order status.
     * 0 = success, 2 = failed, 3 = cancelled (per ABA spec).
     */
    public function mapStatusCode(int|string $statusCode): array
    {
        $statusCode = (int) $statusCode;

        return match ($statusCode) {
            0       => ['payment' => Payment::STATUS_SUCCEEDED, 'order' => Order::STATUS_PAID],
            2       => ['payment' => Payment::STATUS_FAILED,    'order' => null],
            3       => ['payment' => Payment::STATUS_CANCELLED, 'order' => Order::STATUS_CANCELLED],
            default => ['payment' => Payment::STATUS_PENDING,   'order' => null],
        };
    }

    public function generateTranId(Order $order): string
    {
        return strtoupper(substr($order->order_number, -10)).Str::upper(Str::random(6));
    }

    /**
     * Build the items JSON expected by PayWay (base64-encoded JSON of
     * [{name, quantity, price}, …]).
     *
     * Per PayWay's docs the price/quantity here are descriptive only (not
     * used for validation), but we still convert to the same currency we
     * send in `amount` so the customer's checkout summary is coherent.
     */
    public function buildItems(Order $order, float $priceMultiplier = 1.0, int $decimals = 2): string
    {
        $items = $order->items
            ->map(static function ($item) use ($priceMultiplier, $decimals) {
                $snapshot = (array) $item->product_snapshot;

                return [
                    'name'     => (string) ($snapshot['name'] ?? 'Item'),
                    'quantity' => (int) $item->quantity,
                    'price'    => number_format((float) $item->unit_price * $priceMultiplier, $decimals, '.', ''),
                ];
            })
            ->values()
            ->toArray();

        return base64_encode(json_encode($items, JSON_THROW_ON_ERROR));
    }

    /**
     * Generate the PayWay purchase-request hash.
     *
     * PayWay's spec is POSITIONAL, not alphabetical:
     *   - concatenate values in the documented field order (see PURCHASE_HASH_FIELDS)
     *   - missing keys are treated as empty strings
     *   - HMAC-SHA512 with api_key
     *   - base64-encoded raw output.
     */
    public function generateHash(array $payload): string
    {
        $beforeHash = '';
        foreach (self::PURCHASE_HASH_FIELDS as $key) {
            $beforeHash .= (string) ($payload[$key] ?? '');
        }

        $rawHmac = hash_hmac('sha512', $beforeHash, (string) ($this->config['api_key'] ?? ''), true);

        return base64_encode($rawHmac);
    }

    /**
     * Field order required by ABA PayWay's Purchase API for hash generation.
     *
     * Source of truth: https://developer.payway.com.kh/purchase-14530820e0
     * (the "hash" field's PHP sample under the OpenAPI spec).
     *
     * NOTE: `view_type` is intentionally absent — it is a form field but
     * is NOT part of the hash. Adding it will produce "Wrong Hash."
     */
    private const PURCHASE_HASH_FIELDS = [
        'req_time',
        'merchant_id',
        'tran_id',
        'amount',
        'items',
        'shipping',
        'firstname',
        'lastname',
        'email',
        'phone',
        'type',
        'payment_option',
        'return_url',
        'cancel_url',
        'continue_success_url',
        'return_deeplink',
        'currency',
        'custom_fields',
        'return_params',
        'payout',
        'lifetime',
        'additional_params',
        'google_pay_token',
        'skip_success_page',
    ];

    public function trustedIps(): array
    {
        return (array) ($this->config['webhook_ips'] ?? []);
    }
}
