<?php

declare(strict_types=1);

namespace App\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewPromotion
{
    use Dispatchable;
    use SerializesModels;

    public function __construct(
        public string $title,
        public string $body,
        public array $data = [],
        public ?string $topic = null,
    ) {
    }
}
