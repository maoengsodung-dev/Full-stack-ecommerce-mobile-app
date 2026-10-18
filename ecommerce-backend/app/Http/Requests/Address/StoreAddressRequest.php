<?php

declare(strict_types=1);

namespace App\Http\Requests\Address;

use Illuminate\Foundation\Http\FormRequest;

class StoreAddressRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'label'          => ['nullable', 'string', 'max:32'],
            'recipient_name' => ['required', 'string', 'max:120'],
            'phone'          => ['required', 'string', 'max:32'],
            'country'        => ['required', 'string', 'max:64'],
            'province'       => ['required', 'string', 'max:64'],
            'district'       => ['nullable', 'string', 'max:64'],
            'commune'        => ['nullable', 'string', 'max:64'],
            'address_line_1' => ['required', 'string', 'max:191'],
            'address_line_2' => ['nullable', 'string', 'max:191'],
            'postal_code'    => ['nullable', 'string', 'max:16'],
            'latitude'       => ['nullable', 'numeric', 'between:-90,90'],
            'longitude'      => ['nullable', 'numeric', 'between:-180,180'],
            'is_default'     => ['boolean'],
        ];
    }
}
