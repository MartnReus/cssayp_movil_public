<?php

namespace App\Console\Commands;

use App\NotificacionesAfiliado\Jobs\NotificarAfiliadosGeneralJob;
use Illuminate\Console\Command;

class TriggerNotificacionesGenerales extends Command
{
    protected $signature = 'afiliados:notificar';

    protected $description = 'Despacha el proceso masivo de notificaciones generales para afiliados';

    public function handle()
    {
        $this->info('Iniciando despacho del Job de notificaciones...');

        NotificarAfiliadosGeneralJob::dispatch();

        $this->info('Job despachado a la cola "default".');
    }
}
