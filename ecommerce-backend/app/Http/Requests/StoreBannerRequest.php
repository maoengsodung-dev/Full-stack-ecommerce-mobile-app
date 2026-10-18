<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreBannerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    public function rules(): array
    {
        return [
            'title'      => ['nullable', 'string', 'max:200'],
            'subtitle'   => ['nullable', 'string', 'max:500'],
            'image'      => $this->hasFile('image')
                ? ['required', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120']
                : ['required', 'string', 'max:500'],
            'link_type'  => ['nullable', 'string', 'in:none,category,product,external'],
            'link_id'    => ['nullable', 'string', 'max:100'],
            'link_url'   => ['nullable', 'string', 'max:500'],
            'position'   => ['nullable', 'string', 'max:50'],
            'sort_order' => ['nullable', 'integer'],
            'is_active'  => ['nullable', 'boolean'],
            'start_at'   => ['nullable', 'date'],
            'end_at'     => ['nullable', 'date', 'after_or_equal:start_at'],
        ];
    }
}
