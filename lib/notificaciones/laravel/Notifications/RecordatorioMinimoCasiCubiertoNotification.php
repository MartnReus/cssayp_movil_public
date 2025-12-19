<?php

namespace App\NotificacionesAfiliado\Notifications;

use Illuminate\Contracts\Queue\ShouldQueue;

use App\Models\AporteMinimo;

class RecordatorioMinimoCasiCubiertoNotification extends GenericNotification implements ShouldQueue
{
    public const CODE = 'RECORDATORIO_MINIMO_CASI_CUBIERTO';

    private AporteMinimo $aporteMinimo;
    private float $porcentajeFaltante;

    public function __construct(float $porcentajeFaltante)
    {
        $this->aporteMinimo = AporteMinimo::ultimo();
        $this->porcentajeFaltante = $porcentajeFaltante;
        parent::__construct();
    }

    public function getBody(): string
    {
        $montoFaltante = $this->aporteMinimo->importe * ($this->porcentajeFaltante / 100);
        return str_replace('{monto_faltante}', $montoFaltante, $this->notificationTemplate->body_template);
    }
}
