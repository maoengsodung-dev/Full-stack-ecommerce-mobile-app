<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\User;
use App\Services\FCMService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class SendFCMNotification implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public int $tries   = 5;
    public int $timeout = 30;

    /**
     * @param  array{type: string, value: int|string}  $target
     *   type:user (value:user_id), type:topic (value:topic), type:token (value:device_token)
     */
    public function __construct(
        public array $target,
        public string $title,
        public string $body,
        public array $data = [],
    ) {
        $this->onQueue('notifications');
    }

    public function backoff(): array
    {
        return [10, 30, 60, 120, 300];
    }

    public function handle(FCMService $fcm): void
    {
        $type  = $this->target['type'] ?? 'user';
        $value = $this->target['value'] ?? null;

        if ($value === null || $value === '') {
            Log::channel('fcm')->warning('SendFCMNotification: missing target value', $this->target);
            return;
        }

        $event = (string) ($this->data['event'] ?? '');

        switch ($type) {
            case 'user':
                /** @var User|null $user */
                $user = User::find($value);
                if ($user === null) {
                    Log::channel('fcm')->info('SendFCMNotification: user not found', ['value' => $value]);
                    return;
                }
                $fcm->sendToUser($user, $this->title, $this->body, $this->data, $event ?: null);
                break;

            case 'topic':
                $fcm->sendToTopic((string) $value, $this->title, $this->body, $this->data, $event ?: null);
                break;

            case 'token':
                $fcm->sendToToken((string) $value, $this->title, $this->body, $this->data, $event ?: null);
                break;

            default:
                Log::channel('fcm')->warning('SendFCMNotification: unknown target type', ['type' => $type]);
        }
    }

    public function failed(Throwable $e): void
    {
        Log::channel('fcm')->error('SendFCMNotification job failed permanently', [
            'target' => $this->target,
            'title'  => $this->title,
            'error'  => $e->getMessage(),
        ]);
    }
}
