<?php

declare(strict_types=1);

namespace App\Http\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'address_id'     => [
                'required',
                'integer',
                Rule::exists('addresses', 'id')->where('user_id', $this->user()->id),
            ],
            'note'           => ['nullable', 'string', 'max:500'],
            'payment_method' => ['nullable', 'string', Rule::in(['payway', 'cod'])],
            'payment_option' => [
                'nullable',
                'string',
                Rule::in([
                    'cards',
                    'abapay_khqr',
                    'abapay_khqr_deeplink',
                    'abapay_deeplink',
                    'alipay',
                    'wechat',
                    'google_pay',
                    '',
                ]),
            ],
        ];
    }
}
