<?php

namespace App\NotificacionesAfiliado\Notifications;

use App\BoletasGeneradas\Domain\BoletaGenerada;
use Illuminate\Contracts\Queue\ShouldQueue;
use NotificationChannels\Fcm\FcmChannel;
use Illuminate\Notifications\Messages\MailMessage;

class BoletaPorVencerNotification extends GenericNotification implements ShouldQueue
{
    public const CODE = 'BOLETA_POR_VENCER';
    public const DIAS_CONSIDERADOS = 2;

    private BoletaGenerada $boleta;

    public function __construct(BoletaGenerada $boleta)
    {
        $this->boleta = $boleta;
        parent::__construct();
    }

    public function getBody(): string
    {
        return str_replace('{caratula}', $this->boleta->caratula, $this->notificationTemplate->body_template);
    }

    public function via($notifiable): array
    {
        return [FcmChannel::class, 'mail'];
    }

    public function toMail($notifiable)
    {
        $afiliado = $notifiable->load('persona');

        $body1 = 'Su boleta sobre los autos caratulados "' . $this->boleta->caratula . '" vencerá el ' . $this->boleta->fecha_vencimiento->format('d/m/Y') . '.';
        $body2 = "Por favor, realice el pago correspondiente antes de esa fecha.";

        return (new MailMessage)
            ->subject($this->getTitle())
            ->greeting('Estimado ' . $afiliado->persona->nombres . ' ' . $afiliado->persona->apellido)
            ->line($body1)
            ->line($body2)
            ->salutation('Atentamente \nCSSAyP');
    }
}
