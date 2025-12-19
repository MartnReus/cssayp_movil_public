<?php

namespace App\NotificacionesAfiliado\Domain\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DispositivoAfiliado extends Model
{
    use HasFactory;

    protected $connection = 'oracle_cajabot';
    protected $table = 'CJ_BOT.AFILIADO_DISPOSITIVOS';

    protected $fillable = [
        'naf',
        'fcm_token',
        'nombre_dispositivo',
        'plataforma',
        'last_used_at',
    ];
}
