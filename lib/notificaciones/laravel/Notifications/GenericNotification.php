<?php

namespace App\NotificacionesAfiliado\Notifications;

use App\Afiliado\Domain\Afiliado;
use App\NotificacionesAfiliado\Domain\Models\NotificacionTemplate;
use Illuminate\Notifications\Notification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\SerializesModels;
use NotificationChannels\Fcm\FcmMessage;
use NotificationChannels\Fcm\Resources\Notification as FcmNotification;
use NotificationChannels\Fcm\FcmChannel;

abstract class GenericNotification extends Notification implements ShouldQueue
{
    use Queueable, SerializesModels;
    public const CODE = 'GENERIC';

    protected ?NotificacionTemplate $notificationTemplate = null;

    public function __construct()
    {
        $this->notificationTemplate = NotificacionTemplate::where('code', static::CODE)->first();
        if (!$this->notificationTemplate) {
            throw new \Exception("Template not found for code: " . static::CODE);
        }
    }

    public function getTitle(): string
    {
        return $this->notificationTemplate->title_template;
    }

    public function getBody(): string
    {
        return $this->notificationTemplate->body_template;
    }

    public function getTemplateId(): int
    {
        return $this->notificationTemplate->id;
    }

    public function getPriority(): int
    {
        return $this->notificationTemplate->priority;
    }

    public function via($notifiable)
    {
        return [FcmChannel::class];
    }

    public function toFcm($notifiable): FcmMessage
    {
        return (new FcmMessage(
            notification: new FcmNotification(
                title: $this->getTitle(),
                body: $this->getBody()
            )
        ));
    }
}
