<?php

namespace App\NotificacionesAfiliado\Jobs;

use App\Afiliado\Domain\Afiliado;
use App\NotificacionesAfiliado\Domain\Services\NotificacionesService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class NotificarPagosImputadosJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public Afiliado $afiliado;

    public function __construct(Afiliado $afiliado)
    {
        $this->afiliado = $afiliado;
    }

    public function handle(NotificacionesService $notificationService): void
    {
        $notificationService->procesarPagosImputados($this->afiliado);
    }
}
