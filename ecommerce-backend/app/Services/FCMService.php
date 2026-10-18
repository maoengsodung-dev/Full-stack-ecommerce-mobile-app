<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\NotificationLog;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\Messaging\NotFound;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FCMService
{
    public function __construct(
        private readonly ?Messaging $messaging = null
    ) {
    }

    /**
     * Send a push to every active device token a user owns.
     *
     * @param  array<string,mixed>  $data  Custom data payload (must be string => string per FCM spec).
     */
    public function sendToUser(
        User $user,
        string $title,
        string $body,
        array $data = [],
        ?string $event = null
    ): array {
        $tokens = $user->activeDeviceTokens()
            ->pluck('token')
            ->all();

        if (empty($tokens)) {
            return ['success' => 0, 'failure' => 0, 'invalid_tokens' => []];
        }

        $log = NotificationLog::create([
            'user_id'     => $user->id,
            'channel'     => 'fcm',
            'target_type' => 'user',
            'target'      => (string) $user->id,
            'title'       => $title,
            'body'        => $body,
            'data'        => $data,
            'payload'     => ['tokens_count' => count($tokens)],
            'status'      => NotificationLog::STATUS_QUEUED,
            'event'       => $event,
        ]);

        if ($this->messaging === null) {
            Log::channel('fcm')->warning('FCM credentials not found; push notification recorded in log only.', [
                'user_id' => $user->id,
                'title'   => $title,
            ]);
            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => ['simulated' => true, 'reason' => 'credentials_not_found'],
            ]);

            return ['success' => count($tokens), 'failure' => 0, 'invalid_tokens' => [], 'simulated' => true];
        }

        try {
            $message = $this->buildMessage($title, $body, $data);
            $report  = $this->messaging->sendMulticast($message, $tokens);

            $invalidTokens = [];
            foreach ($report->failures()->getItems() as $failure) {
                $token = $failure->target()->value();
                if ($this->isInvalidTokenError($failure->error())) {
                    $invalidTokens[] = $token;
                }
            }

            if (! empty($invalidTokens)) {
                DeviceToken::query()
                    ->whereIn('token', $invalidTokens)
                    ->update(['is_active' => false]);
            }

            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => [
                    'success'        => $report->successes()->count(),
                    'failure'        => $report->failures()->count(),
                    'invalid_tokens' => $invalidTokens,
                ],
            ]);

            return [
                'success'        => $report->successes()->count(),
                'failure'        => $report->failures()->count(),
                'invalid_tokens' => $invalidTokens,
            ];
        } catch (Throwable $e) {
            $log->update([
                'status' => NotificationLog::STATUS_FAILED,
                'error'  => $e->getMessage(),
            ]);

            Log::channel('fcm')->error('FCM sendToUser failed', [
                'user_id' => $user->id,
                'error'   => $e->getMessage(),
            ]);

            return ['success' => 0, 'failure' => count($tokens), 'invalid_tokens' => [], 'error' => $e->getMessage()];
        }
    }

    public function sendToTopic(
        string $topic,
        string $title,
        string $body,
        array $data = [],
        ?string $event = null
    ): array {
        $log = NotificationLog::create([
            'channel'     => 'fcm',
            'target_type' => 'topic',
            'target'      => $topic,
            'title'       => $title,
            'body'        => $body,
            'data'        => $data,
            'payload'     => ['topic' => $topic],
            'status'      => NotificationLog::STATUS_QUEUED,
            'event'       => $event,
        ]);

        if ($this->messaging === null) {
            Log::channel('fcm')->warning('FCM credentials not found; push notification to topic recorded in log only.', [
                'topic' => $topic,
                'title' => $title,
            ]);
            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => ['simulated' => true, 'reason' => 'credentials_not_found'],
            ]);

            return ['success' => true, 'simulated' => true];
        }

        try {
            $message = $this->buildMessage($title, $body, $data)->toTopic($topic);
            $response = $this->messaging->send($message);

            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => ['message_name' => $response['name'] ?? null, 'raw' => $response],
            ]);

            return ['success' => true, 'response' => $response];
        } catch (Throwable $e) {
            $log->update([
                'status' => NotificationLog::STATUS_FAILED,
                'error'  => $e->getMessage(),
            ]);

            Log::channel('fcm')->error('FCM sendToTopic failed', [
                'topic' => $topic,
                'error' => $e->getMessage(),
            ]);

            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    public function sendToToken(
        string $token,
        string $title,
        string $body,
        array $data = [],
        ?string $event = null
    ): array {
        $log = NotificationLog::create([
            'channel'     => 'fcm',
            'target_type' => 'token',
            'target'      => substr($token, 0, 120),
            'title'       => $title,
            'body'        => $body,
            'data'        => $data,
            'status'      => NotificationLog::STATUS_QUEUED,
            'event'       => $event,
        ]);

        if ($this->messaging === null) {
            Log::channel('fcm')->warning('FCM credentials not found; push notification to token recorded in log only.', [
                'token' => substr($token, 0, 15) . '...',
                'title' => $title,
            ]);
            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => ['simulated' => true, 'reason' => 'credentials_not_found'],
            ]);

            return ['success' => true, 'simulated' => true];
        }

        try {
            $message = $this->buildMessage($title, $body, $data)->toToken($token);
            $response = $this->messaging->send($message);

            $log->update([
                'status'   => NotificationLog::STATUS_SENT,
                'response' => ['message_name' => $response['name'] ?? null, 'raw' => $response],
            ]);

            return ['success' => true];
        } catch (NotFound $e) {
            DeviceToken::query()->where('token', $token)->update(['is_active' => false]);
            $log->update([
                'status' => NotificationLog::STATUS_FAILED,
                'error'  => 'invalid_token',
            ]);

            return ['success' => false, 'error' => 'invalid_token'];
        } catch (Throwable $e) {
            $log->update([
                'status' => NotificationLog::STATUS_FAILED,
                'error'  => $e->getMessage(),
            ]);

            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    private function buildMessage(string $title, string $body, array $data): CloudMessage
    {
        $androidCfg = config('fcm.android', []);
        $apnsCfg    = config('fcm.apns', []);

        $stringData = [];
        foreach ($data as $k => $v) {
            $stringData[(string) $k] = is_scalar($v) ? (string) $v : json_encode($v, JSON_THROW_ON_ERROR);
        }

        $message = CloudMessage::new()
            ->withNotification(Notification::create($title, $body))
            ->withData($stringData);

        if (! empty($androidCfg)) {
            $message = $message->withAndroidConfig(AndroidConfig::fromArray([
                'priority'     => $androidCfg['priority'] ?? 'high',
                'notification' => $androidCfg['notification'] ?? [],
            ]));
        }

        if (! empty($apnsCfg)) {
            $message = $message->withApnsConfig(ApnsConfig::fromArray($apnsCfg));
        }

        return $message;
    }

    private function isInvalidTokenError(MessagingException|Throwable $error): bool
    {
        if ($error instanceof NotFound) {
            return true;
        }

        $errorMsg = strtoupper((string) $error->getMessage());
        foreach (config('fcm.invalid_token_errors', []) as $code) {
            if (str_contains($errorMsg, strtoupper((string) $code))) {
                return true;
            }
        }

        return false;
    }
}
