<?php

namespace App\NotificacionesAfiliado\Jobs;

use App\Afiliado\Domain\Afiliado;
use App\NotificacionesAfiliado\Domain\Models\DispositivoAfiliado;
use App\NotificacionesAfiliado\Domain\Services\NotificacionesService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class NotificarAfiliadosGeneralJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct() {}


    public function handle(NotificacionesService $notificationService): void
    {
        $afiliadosConDispositivos = DispositivoAfiliado::pluck('naf')->unique();

        $query = Afiliado::with(['estadoActual'])
            ->whereIn('nro_afiliado', $afiliadosConDispositivos)
            ->where(function ($query) {
                $query->whereHas('estadoActual', function ($q) {
                    $q->where('id_estado_afiliado', '=', '10'); // Afiliado activo
                })
                    ->whereHas('dispositivos');
            });

        \Log::info('Total de afiliados a notificar: ' . $query->count());

        $query->chunkById(100, function ($afiliados) use ($notificationService) {
            foreach ($afiliados as $afiliado) {
                $notificationService->analizarEstadoGeneral($afiliado);
            }
        });
    }
}
