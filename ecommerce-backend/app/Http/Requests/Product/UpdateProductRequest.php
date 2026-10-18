<?php

declare(strict_types=1);

namespace App\Http\Requests\Product;

use App\Models\Product;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        $productId = (int) $this->route('product');

        return [
            'name'              => ['sometimes', 'string', 'max:191'],
            'slug'              => ['sometimes', 'string', 'max:191', Rule::unique('products', 'slug')->ignore($productId)],
            'description'       => ['sometimes', 'nullable', 'string'],
            'short_description' => ['sometimes', 'nullable', 'string', 'max:500'],
            'price'             => ['sometimes', 'numeric', 'min:0'],
            'sale_price'        => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'stock'             => ['sometimes', 'integer', 'min:0'],
            'category_id'       => ['sometimes', 'integer', 'exists:categories,id'],
            'status'            => ['sometimes', Rule::in([
                Product::STATUS_DRAFT, Product::STATUS_ACTIVE, Product::STATUS_INACTIVE, Product::STATUS_ARCHIVED,
            ])],
            'is_featured'       => ['sometimes', 'boolean'],
            'attributes'        => ['sometimes', 'nullable', 'array'],

            'image'               => ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'alt'                 => ['sometimes', 'nullable', 'string', 'max:191'],
            'is_primary'          => ['sometimes', 'boolean'],
            'sort_order'          => ['sometimes', 'integer', 'min:0'],
            'replace_images'      => ['sometimes', 'boolean'],
            'images'              => ['sometimes', 'nullable', 'array'],
            'images.*'            => ['nullable'],
            'images.*.file'       => ['nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'images.*.url'        => ['nullable', 'string', 'max:500'],
            'images.*.alt'        => ['nullable', 'string', 'max:191'],
            'images.*.sort_order' => ['nullable', 'integer', 'min:0'],
            'images.*.is_primary' => ['nullable', 'boolean'],
        ];
    }
}
