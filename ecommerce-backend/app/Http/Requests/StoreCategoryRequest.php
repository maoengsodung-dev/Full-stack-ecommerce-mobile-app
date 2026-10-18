<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAdmin() === true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('name') && ! $this->filled('slug')) {
            $this->merge([
                'slug' => Str::slug((string) $this->input('name')),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'name'        => ['required', 'string', 'max:120', 'unique:categories,name'],
            'slug'        => ['required', 'string', 'max:140', 'unique:categories,slug'],
            'description' => ['nullable', 'string'],
            'icon'        => $this->hasFile('icon')
                ? ['nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:2048']
                : ['nullable', 'string', 'max:191'],
            'image'       => $this->hasFile('image')
                ? ['nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120']
                : ['nullable', 'string', 'max:500'],
            'parent_id'   => ['nullable', 'integer', 'exists:categories,id'],
            'sort_order'  => ['nullable', 'integer'],
            'is_active'   => ['boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.unique' => 'A category with this name already exists.',
            'slug.unique' => 'A category with this slug already exists.',
        ];
    }
}
