<?php

namespace App\NotificacionesAfiliado\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificacionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'type' => $this->notificacionTemplate->code,
            'title' => $this->title,
            'body' => $this->body,
            'sent_at' => $this->sent_at,
            'read_at' => $this->read_at,
        ];
    }
}
