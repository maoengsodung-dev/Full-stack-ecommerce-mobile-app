<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Address extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'label',
        'recipient_name',
        'phone',
        'country',
        'province',
        'district',
        'commune',
        'address_line_1',
        'address_line_2',
        'postal_code',
        'latitude',
        'longitude',
        'is_default',
    ];

    protected function casts(): array
    {
        return [
            'is_default' => 'boolean',
            'latitude'   => 'decimal:7',
            'longitude'  => 'decimal:7',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function toSnapshot(): array
    {
        return [
            'recipient_name' => $this->recipient_name,
            'phone'          => $this->phone,
            'country'        => $this->country,
            'province'       => $this->province,
            'district'       => $this->district,
            'commune'        => $this->commune,
            'address_line_1' => $this->address_line_1,
            'address_line_2' => $this->address_line_2,
            'postal_code'    => $this->postal_code,
            'latitude'       => $this->latitude,
            'longitude'      => $this->longitude,
        ];
    }
}
