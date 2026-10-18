<?php

declare(strict_types=1);

namespace App\Listeners;

use App\Events\NewPromotion;
use App\Jobs\SendFCMNotification;

class BroadcastNewPromotion
{
    public function handle(NewPromotion $event): void
    {
        SendFCMNotification::dispatch(
            target: [
                'type'  => 'topic',
                'value' => $event->topic ?? config('fcm.default_topic', 'promotions'),
            ],
            title: $event->title,
            body:  $event->body,
            data:  array_merge($event->data, ['event' => 'new_promotion']),
        );
    }
}
