<?php

declare(strict_types=1);

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreVariantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        return [
            'sku'          => ['required', 'string', 'max:64', 'unique:product_variants,sku'],
            'size'         => ['nullable', 'string', 'max:32'],
            'color'        => ['nullable', 'string', 'max:32'],
            'price_offset' => ['nullable', 'numeric'],
            'stock'        => ['required', 'integer', 'min:0'],
            'is_active'    => ['boolean'],
        ];
    }
}
