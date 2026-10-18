<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'order_id'       => $this->order_id,
            'gateway'        => $this->gateway,
            'tran_id'        => $this->tran_id,
            'reference'      => $this->reference,
            'amount'         => (float) $this->amount,
            'currency'       => $this->currency,
            'status'         => $this->status,
            'failure_reason' => $this->failure_reason,
            'paid_at'        => $this->paid_at?->toIso8601String(),
            'created_at'     => $this->created_at?->toIso8601String(),
        ];
    }
}
