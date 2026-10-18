<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cart extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'subtotal',
        'total',
        'coupon_code',
        'discount',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'total'    => 'decimal:2',
            'discount' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function recalculate(): void
    {
        $subtotal = $this->items()->sum('line_total');
        $this->subtotal = $subtotal;
        $this->total    = max(0, $subtotal - (float) $this->discount);
        $this->save();
    }
}
