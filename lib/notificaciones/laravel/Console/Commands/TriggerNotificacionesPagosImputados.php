<?php

namespace App\Console\Commands;

use App\Afiliado\Domain\Afiliado;
use App\NotificacionesAfiliado\Jobs\NotificarPagosImputadosJob;
use Illuminate\Console\Command;

class TriggerNotificacionesPagosImputados extends Command
{
    protected $signature = 'afiliados:notificar-pagos-imputados';

    protected $description = 'Despacha el proceso masivo de notificaciones de pagos imputados para afiliados';

    public function handle()
    {
        $this->info('Iniciando despacho del Job de notificaciones...');

        $query = Afiliado::whereHas('dispositivos')
            ->whereHas('movimientos', function ($query) {
                $query->whereDate('fecha_acreditacion', now()->format('Y-m-d'));
            })
            ->with(['movimientos' => function ($query) {

                $query->whereDate('fecha_acreditacion', now()->format('Y-m-d'));
            }, 'dispositivos']);

        $foundAfiliadosCount = $query->count();

        $this->info("Se encontraron {$foundAfiliadosCount} afiliados para notificar en el dia " . now()->format('Y-m-d'));

        $query->chunkById(100, function ($afiliados) {
            foreach ($afiliados as $afiliado) {
                NotificarPagosImputadosJob::dispatch($afiliado);
            }
        });
    }
}
