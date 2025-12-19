<?php

namespace App\NotificacionesAfiliado\Notifications;

use Illuminate\Contracts\Queue\ShouldQueue;

class BoletasPendientesNotification extends GenericNotification implements ShouldQueue
{
    public const CODE = 'BOLETAS_PENDIENTES';

    public function __construct()
    {
        parent::__construct();
    }
}
