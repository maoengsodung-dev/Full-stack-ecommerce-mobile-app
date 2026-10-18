<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Services\PayWayService;
use PHPUnit\Framework\TestCase;

class PayWayServiceTest extends TestCase
{
    public function test_purchase_hash_matches_payway_official_field_order(): void
    {
        $apiKey = 'super-secret-key';
        $service = $this->makeService($apiKey);

        // view_type and a stray field are intentionally provided in the
        // payload to confirm they are NOT included in the hash.
        $payload = [
            'view_type'            => 'hosted_view',
            'extraneous_field'     => 'must-be-ignored',
            'tran_id'              => 'TX123',
            'amount'               => '10.00',
            'items'                => 'base64==',
            'shipping'             => '0.00',
            'firstname'            => 'Jane',
            'lastname'             => 'Doe',
            'email'                => 'jane@example.com',
            'phone'                => '012345678',
            'type'                 => 'purchase',
            'payment_option'       => 'cards',
            'return_url'           => '',
            'cancel_url'           => '',
            'continue_success_url' => '',
            'return_deeplink'      => '',
            'currency'             => 'USD',
            'custom_fields'        => '',
            'return_params'        => '',
            'payout'               => '',
            'lifetime'             => '',
            'additional_params'    => '',
            'google_pay_token'     => '',
            'skip_success_page'    => '',
            'merchant_id'          => 'ec000001',
            'req_time'             => '20250101000000',
        ];

        $beforeHash = $payload['req_time']
            . $payload['merchant_id']
            . $payload['tran_id']
            . $payload['amount']
            . $payload['items']
            . $payload['shipping']
            . $payload['firstname']
            . $payload['lastname']
            . $payload['email']
            . $payload['phone']
            . $payload['type']
            . $payload['payment_option']
            . $payload['return_url']
            . $payload['cancel_url']
            . $payload['continue_success_url']
            . $payload['return_deeplink']
            . $payload['currency']
            . $payload['custom_fields']
            . $payload['return_params']
            . $payload['payout']
            . $payload['lifetime']
            . $payload['additional_params']
            . $payload['google_pay_token']
            . $payload['skip_success_page'];

        $expected = base64_encode(hash_hmac('sha512', $beforeHash, $apiKey, true));

        $this->assertSame($expected, $service->generateHash($payload));
    }

    public function test_per_request_payment_option_changes_signed_hash(): void
    {
        // The mobile app overrides `payment_option` per checkout (e.g. KHQR
        // deeplink vs hosted cards page). Because it sits at position 12 of
        // PURCHASE_HASH_FIELDS, swapping it MUST yield a different hash —
        // otherwise the override would be silently ignored by PayWay.
        $apiKey  = 'override-key';
        $service = $this->makeService($apiKey);

        $base = [
            'req_time'    => '20250101000000',
            'merchant_id' => 'ec000001',
            'tran_id'     => 'TX-OVR',
            'amount'      => '40000',
            'items'       => 'base64==',
            'shipping'    => '0',
            'firstname'   => 'Jane',
            'lastname'    => 'Doe',
            'email'       => 'jane@example.com',
            'phone'       => '012345678',
            'type'        => 'purchase',
            'currency'    => 'KHR',
        ];

        $hashCards   = $service->generateHash($base + ['payment_option' => 'cards']);
        $hashKhqr    = $service->generateHash($base + ['payment_option' => 'abapay_khqr_deeplink']);
        $hashEmpty   = $service->generateHash($base + ['payment_option' => '']);

        // Each variant produces a distinct signature.
        $this->assertNotSame($hashCards, $hashKhqr);
        $this->assertNotSame($hashCards, $hashEmpty);
        $this->assertNotSame($hashKhqr, $hashEmpty);

        // And each one is exactly what HMAC-SHA512 would produce for that
        // value at position 12 of the official field order.
        $manual = function (string $option) use ($base, $apiKey): string {
            $payload = $base + ['payment_option' => $option];
            $beforeHash = $payload['req_time']
                . $payload['merchant_id']
                . $payload['tran_id']
                . $payload['amount']
                . $payload['items']
                . $payload['shipping']
                . $payload['firstname']
                . $payload['lastname']
                . $payload['email']
                . $payload['phone']
                . $payload['type']
                . $payload['payment_option']
                . $payload['currency'];

            return base64_encode(hash_hmac('sha512', $beforeHash, $apiKey, true));
        };

        $this->assertSame($manual('cards'), $hashCards);
        $this->assertSame($manual('abapay_khqr_deeplink'), $hashKhqr);
        $this->assertSame($manual(''), $hashEmpty);
    }

    public function test_purchase_hash_treats_missing_fields_as_empty_strings(): void
    {
        $apiKey = 'k';
        $service = $this->makeService($apiKey);

        $payload = [
            'req_time'    => '20250101000000',
            'merchant_id' => 'ec000001',
        ];

        $expected = base64_encode(hash_hmac(
            'sha512',
            '20250101000000' . 'ec000001',
            $apiKey,
            true,
        ));

        $this->assertSame($expected, $service->generateHash($payload));
    }

    public function test_webhook_signature_uses_ksort_with_json_encoded_arrays(): void
    {
        $apiKey = 'webhook-secret';
        $service = $this->makeService($apiKey);

        $body = [
            'tran_id'       => '17425401324',
            'apv'           => '619195',
            'status'        => '0',
            'return_params' => 'extra-info',
        ];

        ksort($body);
        $beforeHash = '';
        foreach ($body as $value) {
            if (is_array($value)) {
                $value = json_encode($value, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            }
            $beforeHash .= (string) $value;
        }
        $expected = base64_encode(hash_hmac('sha512', $beforeHash, $apiKey, true));

        $this->assertTrue($service->verifyWebhookSignature($body, $expected));
        $this->assertFalse($service->verifyWebhookSignature($body, 'tampered'));
        $this->assertFalse($service->verifyWebhookSignature($body, ''));
    }

    private function makeService(string $apiKey): PayWayService
    {
        return new PayWayService([
            'mode'           => 'sandbox',
            'merchant_id'    => 'ec000001',
            'api_key'        => $apiKey,
            'currency'       => 'USD',
            'view_type'      => 'hosted_view',
            'payment_option' => 'cards',
            'endpoints'      => [
                'sandbox'    => ['base_url' => 'https://sandbox', 'purchase' => '/p'],
                'production' => ['base_url' => 'https://prod',    'purchase' => '/p'],
            ],
            'urls'        => [],
            'webhook_ips' => [],
            'http'        => ['timeout' => 5, 'connect_timeout' => 5],
        ]);
    }

    public function test_status_code_mapping(): void
    {
        $service = new PayWayService(['mode' => 'sandbox', 'api_key' => 'k']);

        $this->assertSame('succeeded', $service->mapStatusCode(0)['payment']);
        $this->assertSame('paid',      $service->mapStatusCode(0)['order']);
        $this->assertSame('failed',    $service->mapStatusCode(2)['payment']);
        $this->assertSame('cancelled', $service->mapStatusCode(3)['payment']);
        $this->assertSame('cancelled', $service->mapStatusCode(3)['order']);
    }

    public function test_build_items_converts_prices_to_target_currency(): void
    {
        $service = $this->makeService('k');

        $order = $this->fakeOrderWithItems([
            ['name' => 'A', 'quantity' => 1, 'unit_price' => 9.99],
            ['name' => 'B', 'quantity' => 2, 'unit_price' => 1.50],
        ]);

        // No conversion: USD prices preserved with 2 decimals.
        $usd = json_decode(base64_decode($service->buildItems($order, 1.0, 2)), true);
        $this->assertSame('9.99', $usd[0]['price']);
        $this->assertSame('1.50', $usd[1]['price']);

        // USD → KHR at 4100: integers, no decimals.
        $khr = json_decode(base64_decode($service->buildItems($order, 4100.0, 0)), true);
        $this->assertSame('40959', $khr[0]['price']);
        $this->assertSame('6150',  $khr[1]['price']);
    }

    private function fakeOrderWithItems(array $rows): \App\Models\Order
    {
        $items = collect($rows)->map(fn ($r) => (object) [
            'product_snapshot' => ['name' => $r['name']],
            'quantity'         => $r['quantity'],
            'unit_price'       => $r['unit_price'],
        ]);

        $order = new class extends \App\Models\Order {
            public $items;
        };
        $order->items = $items;

        return $order;
    }
}
