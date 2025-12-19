<?php

namespace App\NotificacionesAfiliado\Domain\Services;

use App\Afiliado\Domain\Afiliado;
use App\Aporte\Application\AporteService;
use App\BoletasGeneradas\Domain\BoletaGenerada;
use App\NotificacionesAfiliado\Domain\Models\NotificacionAfiliado;
use App\NotificacionesAfiliado\Domain\Models\NotificacionTemplate;
use App\NotificacionesAfiliado\Notifications\BoletaPorVencerNotification;
use App\NotificacionesAfiliado\Notifications\BoletasPendientesNotification;
use App\NotificacionesAfiliado\Notifications\GenericNotification;
use App\NotificacionesAfiliado\Notifications\PagosImputadosNotificacion;
use App\NotificacionesAfiliado\Notifications\RecordatorioAportesNotification;
use App\NotificacionesAfiliado\Notifications\RecordatorioMinimoCasiCubiertoNotification;
use Illuminate\Support\Facades\Log;

class NotificacionesService
{

    const FRECUENCIA_EN_DIAS = [
        'BOLETA_POR_VENCER' => 2,      // Cada 2 días
        'BOLETAS_PENDIENTES' => 3,     // Cada 3 días
        'RECORDATORIO_APORTES' => 7,   // Cada semana
        'PAGOS_IMPUTADOS' => 0,        // Siempre se puede enviar
        'MINIMO_CASI_CUBIERTO' => 7,  // Cada semana (que se envia si el porcentaje es menor a 100 y mayor a 75)
    ];

    const THRESHOLD_DIFERENCIA_PORCENTAJES = 15;

    private AporteService $aporteService;

    public function __construct(AporteService $aporteService)
    {
        $this->aporteService = $aporteService;
    }

    public function analizarEstadoGeneral(Afiliado $afiliado): void
    {
        $afiliado = $afiliado->load('boletasGeneradas');

        /** @var \Illuminate\Support\Collection<GenericNotification> $notificacionesCandidatas */
        $notificacionesCandidatas = collect();

        $boleta = $this->checkBoletasPorVencer($afiliado, 2);
        if (!empty($boleta)) {
            $notificacion = new BoletaPorVencerNotification($boleta);
            $notificacionesCandidatas->push([
                "notification" => $notificacion,
                "priority" => $notificacion->getPriority()
            ]);
        }

        if ($this->checkBoletasPendientes($afiliado)) {
            $notificacion = new BoletasPendientesNotification();
            $notificacionesCandidatas->push([
                "notification" => $notificacion,
                "priority" => $notificacion->getPriority()
            ]);
        }

        $porcentajeAportado = $this->aporteService->calcularPorcentajeAportado($afiliado);
        if ($this->checkMinimoCasiCubierto($afiliado, $porcentajeAportado)) {
            $notificacion = new RecordatorioMinimoCasiCubiertoNotification(porcentajeFaltante: 100 - $porcentajeAportado);
            $notificacionesCandidatas->push([
                "notification" => $notificacion,
                "priority" => $notificacion->getPriority()
            ]);
        }

        if ($this->checkRecordatorioAportes($afiliado, $porcentajeAportado)) {
            $notificacion = new RecordatorioAportesNotification();
            $notificacionesCandidatas->push([
                "notification" => $notificacion,
                "priority" => $notificacion->getPriority()
            ]);
        }


        if ($notificacionesCandidatas->count() === 0) {
            Log::info('No hay notificaciones para el afiliado ' . $afiliado->nro_afiliado);
            return;
        }
        Log::info('Notificaciones candidatas para el afiliado ' . $afiliado->nro_afiliado . ': ' . $notificacionesCandidatas->count());

        $notificacionGanadora = $notificacionesCandidatas->sortByDesc('priority')->first();

        Log::info('Notificacion para el afiliado ' . $afiliado->nro_afiliado . ': ' . $notificacionGanadora['notification']->getTitle());
        Log::info('Prioridad: ' . $notificacionGanadora['priority']);
        $afiliado->notify($notificacionGanadora['notification']);

        $this->logNotification($afiliado, $notificacionGanadora['notification']);
    }

    public function procesarPagosImputados(Afiliado $afiliado): void
    {
        $notificacion = new PagosImputadosNotificacion($afiliado);
        $afiliado->notify($notificacion);
        $this->logNotification($afiliado, $notificacion);
    }

    private function checkBoletasPorVencer(Afiliado $afiliado, int $dias): ?BoletaGenerada
    {
        $template = NotificacionTemplate::where('code', BoletaPorVencerNotification::CODE)->first();
        if (!$this->shouldSend($afiliado, $template)) {
            return null;
        }

        return $afiliado->boletasGeneradas()
            ->proximasAVencer($dias)
            ->first();
    }

    private function checkBoletasPendientes(Afiliado $afiliado): bool
    {
        $template = NotificacionTemplate::where('code', BoletasPendientesNotification::CODE)->first();
        if (!$this->shouldSend($afiliado, $template)) {
            return false;
        }

        return $afiliado->boletasGeneradas()
            ->noImputadas()
            ->noVencidas()
            ->exists();
    }

    private function checkMinimoCasiCubierto(Afiliado $afiliado, float $porcentajeAportado): bool
    {
        $template = NotificacionTemplate::where('code', RecordatorioMinimoCasiCubiertoNotification::CODE)->first();
        if (!$this->shouldSend($afiliado, $template)) {
            return false;
        }

        return $porcentajeAportado < 100 && $porcentajeAportado >= 75;
    }

    private function checkRecordatorioAportes(Afiliado $afiliado, float $porcentajeAportado): bool
    {
        $template = NotificacionTemplate::where('code', RecordatorioAportesNotification::CODE)->first();
        if (!$this->shouldSend($afiliado, $template)) {
            return false;
        }

        $now = now()->dayOfYear();
        $ultimoDiaAnio = now()->endOfYear()->dayOfYear();

        $diasRestantesPorcentaje = ($ultimoDiaAnio / $now) * 100;
        $diferenciaPorcentajes = $diasRestantesPorcentaje - $porcentajeAportado;

        return $diferenciaPorcentajes > self::THRESHOLD_DIFERENCIA_PORCENTAJES;
    }

    private function shouldSend(Afiliado $afiliado, NotificacionTemplate $template): bool
    {
        $cooldownDias = self::FRECUENCIA_EN_DIAS[$template->code] ?? 1;

        if ($cooldownDias === 0) {
            return true;
        }

        $ultimoEnvio = NotificacionAfiliado::where('naf', $afiliado->nro_afiliado)
            ->where('template_id', $template->id)
            ->latest('created_at')
            ->first();

        if (!$ultimoEnvio) {
            return true;
        }

        return $ultimoEnvio->created_at->diffInDays(now()) >= $cooldownDias;
    }

    private function logNotification(Afiliado $afiliado, $notification): void
    {
        NotificacionAfiliado::create([
            'naf' => $afiliado->nro_afiliado,
            'template_id' => $notification->getTemplateId(),
            'title' => $notification->getTitle(),
            'body' => $notification->getBody(),
            'data_payload' => null,
            'sent_at' => now(),
        ]);
    }
}
