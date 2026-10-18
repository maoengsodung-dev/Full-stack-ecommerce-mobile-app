<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory;
    use SoftDeletes;

    public const STATUS_PENDING    = 'pending';
    public const STATUS_PAID       = 'paid';
    public const STATUS_PROCESSING = 'processing';
    public const STATUS_SHIPPED    = 'shipped';
    public const STATUS_DELIVERED  = 'delivered';
    public const STATUS_CANCELLED  = 'cancelled';
    public const STATUS_REFUNDED   = 'refunded';

    public const PAYMENT_UNPAID   = 'unpaid';
    public const PAYMENT_PAID     = 'paid';
    public const PAYMENT_FAILED   = 'failed';
    public const PAYMENT_REFUNDED = 'refunded';

    public const TRANSITIONS = [
        self::STATUS_PENDING    => [self::STATUS_PROCESSING, self::STATUS_PAID, self::STATUS_CANCELLED],
        self::STATUS_PAID       => [self::STATUS_PROCESSING, self::STATUS_REFUNDED, self::STATUS_CANCELLED],
        self::STATUS_PROCESSING => [self::STATUS_SHIPPED, self::STATUS_CANCELLED],
        self::STATUS_SHIPPED    => [self::STATUS_DELIVERED, self::STATUS_REFUNDED],
        self::STATUS_DELIVERED  => [self::STATUS_REFUNDED],
        self::STATUS_CANCELLED  => [],
        self::STATUS_REFUNDED   => [],
    ];

    protected $fillable = [
        'order_number',
        'user_id',
        'address_id',
        'shipping_snapshot',
        'subtotal',
        'shipping_fee',
        'tax',
        'discount',
        'total',
        'currency',
        'status',
        'payment_status',
        'payment_method',
        'coupon_code',
        'note',
        'tracking_number',
        'paid_at',
        'shipped_at',
        'delivered_at',
        'cancelled_at',
    ];

    protected function casts(): array
    {
        return [
            'shipping_snapshot' => 'array',
            'subtotal'          => 'decimal:2',
            'shipping_fee'      => 'decimal:2',
            'tax'               => 'decimal:2',
            'discount'          => 'decimal:2',
            'total'             => 'decimal:2',
            'paid_at'           => 'datetime',
            'shipped_at'        => 'datetime',
            'delivered_at'      => 'datetime',
            'cancelled_at'      => 'datetime',
        ];
    }

    public function getRouteKeyName(): string
    {
        return 'order_number';
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function address(): BelongsTo
    {
        return $this->belongsTo(Address::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function latestPayment(): HasOne
    {
        return $this->hasOne(Payment::class)->latestOfMany();
    }

    public function canTransitionTo(string $status): bool
    {
        return in_array($status, self::TRANSITIONS[$this->status] ?? [], true);
    }

    public function isCancellable(): bool
    {
        return in_array($this->status, [self::STATUS_PENDING, self::STATUS_PAID, self::STATUS_PROCESSING], true);
    }

    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }

    public function scopeStatus(Builder $query, string|array $status): Builder
    {
        return $query->whereIn('status', (array) $status);
    }
}
