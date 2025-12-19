<?php

namespace App\NotificacionesAfiliado\Notifications;

use App\Afiliado\Domain\Afiliado;
use Illuminate\Contracts\Queue\ShouldQueue;

class RecordatorioAportesNotification extends GenericNotification implements ShouldQueue
{
    public const CODE = 'RECORDATORIO_APORTES';

    public function __construct()
    {
        parent::__construct();
    }
}
