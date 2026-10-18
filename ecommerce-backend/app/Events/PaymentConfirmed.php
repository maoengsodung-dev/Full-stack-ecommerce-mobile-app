<?php

declare(strict_types=1);

namespace App\Events;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class PaymentConfirmed
{
    use Dispatchable;
    use SerializesModels;

    public function __construct(
        public Order $order,
        public Payment $payment,
    ) {
    }
}
