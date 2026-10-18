<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBannerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        return [
            'title'      => ['sometimes', 'nullable', 'string', 'max:200'],
            'subtitle'   => ['sometimes', 'nullable', 'string', 'max:500'],
            'image'      => $this->hasFile('image')
                ? ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120']
                : ['sometimes', 'nullable', 'string', 'max:500'],
            'link_type'  => ['sometimes', 'nullable', 'string', 'in:none,category,product,external'],
            'link_id'    => ['sometimes', 'nullable', 'string', 'max:100'],
            'link_url'   => ['sometimes', 'nullable', 'string', 'max:500'],
            'position'   => ['sometimes', 'nullable', 'string', 'max:50'],
            'sort_order' => ['sometimes', 'integer'],
            'is_active'  => ['sometimes', 'boolean'],
            'start_at'   => ['sometimes', 'nullable', 'date'],
            'end_at'     => ['sometimes', 'nullable', 'date', 'after_or_equal:start_at'],
        ];
    }
}
