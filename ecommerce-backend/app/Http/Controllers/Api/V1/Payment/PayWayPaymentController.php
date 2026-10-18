<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Payment;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PayWayPaymentController extends Controller
{
    /**
     * POST /api/v1/payments/payway/create
     * Receives: {"order_id": 1001, "payment_method": "payway"}
     */
    public function create(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'order_id' => ['required', 'integer'],
            'payment_method' => ['nullable', 'string'],
        ]);

        $order = Order::where('id', $validated['order_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        // 1. Generate unique PayWay transaction ID and timestamp
        $tranId = 'ORD-' . $order->id . '-' . time();
        $reqTime = date('YmdHis');
        $amount = number_format((float) $order->total, 2, '.', '');
        $currency = 'USD'; // or 'KHR'

        $merchantId = config('services.payway.merchant_id', env('PAYWAY_MERCHANT_ID'));
        $apiKey = config('services.payway.api_key', env('PAYWAY_API_KEY'));
        $paywayApiUrl = config('services.payway.api_url', env('PAYWAY_API_URL', 'https://checkout-sandbox.payway.com.kh'));
        $returnUrl = base64_encode(url('/api/v1/payments/payway/return'));

        // 2. Prepare items base64 encoded
        $items = base64_encode(json_encode([
            [
                'name' => 'Order #' . ($order->order_number ?? $order->id),
                'quantity' => 1,
                'price' => (float) $amount,
            ]
        ]));

        // 3. Generate HMAC SHA-512 Hash according to ABA PayWay specs
        // hash_hmac('sha512', $reqTime . $merchantId . $tranId . $amount . $items . ... , $apiKey)
        $hashData = $reqTime . $merchantId . $tranId . $amount . $items;
        $hash = base64_encode(hash_hmac('sha512', $hashData, $apiKey, true));

        // 4. Build standard PayWay Checkout HTML / Hosted Payment URL
        $checkoutUrl = "{$paywayApiUrl}/api/payment-gateway/v1/payments/purchase";

        return response()->json([
            'success' => true,
            'tran_id' => $tranId,
            'checkout_url' => $checkoutUrl,
            'checkout_html' => view('payway.checkout_form', [
                'api_url' => $checkoutUrl,
                'req_time' => $reqTime,
                'merchant_id' => $merchantId,
                'tran_id' => $tranId,
                'amount' => $amount,
                'items' => $items,
                'hash' => $hash,
                'firstname' => $request->user()->name ?? 'Customer',
                'phone' => $order->address->phone ?? '012345678',
                'return_url' => $returnUrl,
            ])->render(),
            'abapay_deeplink' => null, // Populated if using ABA PAY KHQR API
            'amount' => (float) $amount,
            'currency' => $currency,
        ]);
    }

    /**
     * GET /api/v1/payments/payway/status/{tranId}
     */
    public function status(Request $request, string $tranId): JsonResponse
    {
        // 1. Query verified transaction from DB or directly verify with PayWay Check-Transaction API
        $merchantId = config('services.payway.merchant_id', env('PAYWAY_MERCHANT_ID'));
        $apiKey = config('services.payway.api_key', env('PAYWAY_API_KEY'));
        $paywayApiUrl = config('services.payway.api_url', env('PAYWAY_API_URL', 'https://checkout-sandbox.payway.com.kh'));

        $reqTime = date('YmdHis');
        $hash = base64_encode(hash_hmac('sha512', $reqTime . $merchantId . $tranId, $apiKey, true));

        try {
            $response = Http::asForm()->post("{$paywayApiUrl}/api/payment-gateway/v1/payments/check-transaction", [
                'req_time' => $reqTime,
                'merchant_id' => $merchantId,
                'tran_id' => $tranId,
                'hash' => $hash,
            ]);

            $paywayData = $response->json();
            $statusCode = (string) ($paywayData['status'] ?? '1');
            $paymentStatus = $statusCode === '0' ? 'paid' : ($statusCode === '1' ? 'pending' : 'failed');

            // Extract order ID from tran_id (ORD-{id}-{timestamp})
            $orderId = explode('-', $tranId)[1] ?? null;
            $order = $orderId ? Order::find($orderId) : null;

            if ($order && $paymentStatus === 'paid' && $order->payment_status !== 'paid') {
                $order->update([
                    'payment_status' => 'paid',
                    'status' => 'processing',
                ]);
            }

            return response()->json([
                'success' => true,
                'status' => $paymentStatus,
                'payment' => [
                    'tran_id' => $tranId,
                    'status' => $paymentStatus,
                    'amount' => (float) ($paywayData['amount'] ?? ($order->total ?? 0)),
                    'currency' => $paywayData['currency'] ?? 'USD',
                    'payment_choice' => $paywayData['payment_choice'] ?? 'ABA PayWay',
                ],
                'order' => [
                    'id' => $order?->id,
                    'order_number' => $order?->order_number ?? 'ORD-' . $orderId,
                    'status' => $order?->status ?? 'pending',
                ],
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'status' => 'pending',
                'message' => 'Status check in progress',
            ]);
        }
    }
}
