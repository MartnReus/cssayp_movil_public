<?php

namespace App\NotificacionesAfiliado\Notifications;

use App\Afiliado\Domain\Afiliado;
use Illuminate\Contracts\Queue\ShouldQueue;


class PagosImputadosNotificacion extends GenericNotification implements ShouldQueue
{
    public const CODE = 'PAGOS_IMPUTADOS';

    public function __construct()
    {
        parent::__construct();
    }
}
