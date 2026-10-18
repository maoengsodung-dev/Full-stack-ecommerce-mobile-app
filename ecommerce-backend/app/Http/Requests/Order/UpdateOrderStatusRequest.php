<?php

declare(strict_types=1);

namespace App\Http\Requests\Order;

use App\Models\Order;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateOrderStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        return [
            'status' => [
                'required',
                Rule::in([
                    Order::STATUS_PAID,
                    Order::STATUS_PROCESSING,
                    Order::STATUS_SHIPPED,
                    Order::STATUS_DELIVERED,
                    Order::STATUS_CANCELLED,
                    Order::STATUS_REFUNDED,
                ]),
            ],
            'tracking_number' => ['nullable', 'string', 'max:64'],
        ];
    }
}
