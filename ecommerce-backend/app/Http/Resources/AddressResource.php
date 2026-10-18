<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'label'          => $this->label,
            'recipient_name' => $this->recipient_name,
            'phone'          => $this->phone,
            'country'        => $this->country,
            'province'       => $this->province,
            'district'       => $this->district,
            'commune'        => $this->commune,
            'address_line_1' => $this->address_line_1,
            'address_line_2' => $this->address_line_2,
            'postal_code'    => $this->postal_code,
            'latitude'       => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude'      => $this->longitude !== null ? (float) $this->longitude : null,
            'is_default'     => (bool) $this->is_default,
            'created_at'     => $this->created_at?->toIso8601String(),
        ];
    }
}
