<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreDeviceTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'token'       => ['required', 'string', 'max:512'],
            'platform'    => ['required', Rule::in(['ios', 'android', 'web'])],
            'device_id'   => ['nullable', 'string', 'max:191'],
            'app_version' => ['nullable', 'string', 'max:32'],
        ];
    }
}
