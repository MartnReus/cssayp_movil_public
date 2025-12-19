<?php

namespace App\NotificacionesAfiliado\Domain\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class NotificacionTemplate extends Model
{
    use HasFactory;
    protected $connection = 'oracle_cajabot';
    protected $table = 'NOTIFICACION_TEMPLATES';

    protected $fillable = [
        'code',
        'title_template',
        'body_template',
        'channels',
        'is_active',
    ];

    protected function channels(): Attribute
    {
        return Attribute::make(
            get: fn(?string $value) => $value ? explode('|', $value) : [],

            set: fn(array $value) => implode('|', $value),
        );
    }

    protected function isActive(): Attribute
    {
        return Attribute::make(
            get: fn(?int $value) => $value ? true : false,

            set: fn(bool $value) => $value ? 1 : 0,
        );
    }
}
