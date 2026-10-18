<?php

declare(strict_types=1);

namespace App\Http\Requests\Address;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAddressRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'label'          => ['sometimes', 'nullable', 'string', 'max:32'],
            'recipient_name' => ['sometimes', 'string', 'max:120'],
            'phone'          => ['sometimes', 'string', 'max:32'],
            'country'        => ['sometimes', 'string', 'max:64'],
            'province'       => ['sometimes', 'string', 'max:64'],
            'district'       => ['sometimes', 'nullable', 'string', 'max:64'],
            'commune'        => ['sometimes', 'nullable', 'string', 'max:64'],
            'address_line_1' => ['sometimes', 'string', 'max:191'],
            'address_line_2' => ['sometimes', 'nullable', 'string', 'max:191'],
            'postal_code'    => ['sometimes', 'nullable', 'string', 'max:16'],
            'latitude'       => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'longitude'      => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'is_default'     => ['sometimes', 'boolean'],
        ];
    }
}
