<?php

namespace App\NotificacionesAfiliado\Domain\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class NotificacionAfiliado extends Model
{
    use HasFactory;

    protected $connection = 'oracle_cajabot';
    protected $table = 'AFILIADO_NOTIFICACIONES';

    protected $fillable = [
        'naf',
        'template_id',
        'title',
        'body',
        'data_payload',
        'sent_at',
        'read_at',
        'external_id',
        'uuid',
    ];

    protected static function booted(): void
    {
        static::creating(function (NotificacionAfiliado $model) {
            if (empty($model->uuid)) {
                $model->uuid = (string) Str::uuid();
            }
        });
    }

    public function notificacionTemplate()
    {
        return $this->belongsTo(NotificacionTemplate::class, 'template_id', 'id');
    }
}
