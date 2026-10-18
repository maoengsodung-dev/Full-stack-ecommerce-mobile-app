<?php

declare(strict_types=1);

namespace App\Providers;

use App\Events\NewPromotion;
use App\Events\OrderShipped;
use App\Events\OrderStatusChanged;
use App\Events\PaymentConfirmed;
use App\Listeners\BroadcastNewPromotion;
use App\Listeners\SendOrderStatusNotification;
use App\Listeners\SendPaymentConfirmedNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        OrderStatusChanged::class => [
            [SendOrderStatusNotification::class, 'handleOrderStatusChanged'],
        ],
        OrderShipped::class => [
            [SendOrderStatusNotification::class, 'handleOrderShipped'],
        ],
        PaymentConfirmed::class => [
            SendPaymentConfirmedNotification::class,
        ],
        NewPromotion::class => [
            BroadcastNewPromotion::class,
        ],
    ];

    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
