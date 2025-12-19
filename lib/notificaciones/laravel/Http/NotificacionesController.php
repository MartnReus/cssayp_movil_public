<?php

namespace App\NotificacionesAfiliado\Http;

use App\NotificacionesAfiliado\Http\Resources\NotificacionResource;
use App\NotificacionesAfiliado\Domain\Models\DispositivoAfiliado;
use App\NotificacionesAfiliado\Domain\Models\NotificacionAfiliado;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class NotificacionesController
{
    public function registrarDispositivo(Request $request)
    {
        $request->validate([
            'fcmToken' => 'required',
            'nroAfiliado' => 'required',
            'nombreDispositivo' => 'required',
            'plataforma' => 'required',
        ]);

        // Actualiza el dispositivo si el token existe, o crea uno nuevo
        $dispositivo = DispositivoAfiliado::updateOrCreate(
            ['fcm_token' => $request->fcmToken],
            [
                'naf' => $request->nroAfiliado,
                'nombre_dispositivo' => $request->nombreDispositivo,
                'plataforma' => $request->plataforma,
                'last_used_at' => now(),
            ]
        );

        return response()->json([
            'message' => 'Dispositivo registrado exitosamente',
            'dispositivo' => $dispositivo,
        ]);
    }

    public function obtenerNotificaciones(string $nroAfiliado)
    {
        $page_size = 10;

        $notificaciones = NotificacionAfiliado::where('naf', $nroAfiliado)->with('notificacionTemplate')->simplePaginate($page_size);
        return NotificacionResource::collection($notificaciones);
    }

    public function marcarLeido(Request $request)
    {
        $request->validate([
            'uuidList' => 'required|array',
            'uuidList.*' => 'string',
        ]);

        foreach ($request->uuidList as $notificacion_uuid) {
            $notificacion = NotificacionAfiliado::where('uuid', $notificacion_uuid)->first();
            if (!$notificacion) {
                return response()->json([
                    'message' => 'Notificación no encontrada',
                ], 404);
            }

            $notificacion->read_at = now();
            $notificacion->save();
        }

        return response()->json([
            'message' => 'Notificaciones marcadas como leidas',
        ]);
    }
}
