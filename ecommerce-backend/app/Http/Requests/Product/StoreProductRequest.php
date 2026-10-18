<?php

declare(strict_types=1);

namespace App\Http\Requests\Product;

use App\Models\Product;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        return [
            'name'              => ['required', 'string', 'max:191'],
            'slug'              => ['nullable', 'string', 'max:191', 'unique:products,slug'],
            'description'       => ['nullable', 'string'],
            'short_description' => ['nullable', 'string', 'max:500'],
            'price'             => ['required', 'numeric', 'min:0'],
            'sale_price'        => ['nullable', 'numeric', 'min:0', 'lt:price'],
            'stock'             => ['required', 'integer', 'min:0'],
            'category_id'       => ['required', 'integer', 'exists:categories,id'],
            'status'            => ['required', Rule::in([
                Product::STATUS_DRAFT, Product::STATUS_ACTIVE, Product::STATUS_INACTIVE, Product::STATUS_ARCHIVED,
            ])],
            'is_featured'       => ['boolean'],
            'attributes'        => ['nullable', 'array'],

            'image'                   => ['nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'alt'                     => ['nullable', 'string', 'max:191'],
            'is_primary'              => ['nullable', 'boolean'],
            'sort_order'              => ['nullable', 'integer', 'min:0'],
            'images'                  => ['nullable', 'array'],
            'images.*'                => ['nullable'],
            'images.*.file'           => ['nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'images.*.url'            => ['nullable', 'string', 'max:500'],
            'images.*.alt'            => ['nullable', 'string', 'max:191'],
            'images.*.sort_order'     => ['nullable', 'integer', 'min:0'],
            'images.*.is_primary'     => ['nullable', 'boolean'],
        ];
    }
}
