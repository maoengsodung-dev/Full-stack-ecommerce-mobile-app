<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationLog extends Model
{
    use HasFactory;

    public const STATUS_QUEUED = 'queued';
    public const STATUS_SENT   = 'sent';
    public const STATUS_FAILED = 'failed';

    protected $fillable = [
        'user_id',
        'channel',
        'target_type',
        'target',
        'title',
        'body',
        'data',
        'payload',
        'response',
        'status',
        'error',
        'event',
    ];

    protected function casts(): array
    {
        return [
            'data'     => 'array',
            'payload'  => 'array',
            'response' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
