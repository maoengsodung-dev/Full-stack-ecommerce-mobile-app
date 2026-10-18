<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    public const STATUS_INITIATED = 'initiated';
    public const STATUS_PENDING   = 'pending';
    public const STATUS_SUCCEEDED = 'succeeded';
    public const STATUS_FAILED    = 'failed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_REFUNDED  = 'refunded';

    protected $fillable = [
        'order_id',
        'gateway',
        'tran_id',
        'reference',
        'amount',
        'currency',
        'status',
        'payload',
        'webhook_response',
        'failure_reason',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'amount'           => 'decimal:2',
            'payload'          => 'array',
            'webhook_response' => 'array',
            'paid_at'          => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
