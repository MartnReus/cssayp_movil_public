# Diseño de Base de Datos para Notificaciones

Este documento define la arquitectura de datos para el sistema de notificaciones, siguiendo un enfoque **Database-First** y separando la **Definición** (qué se puede enviar) de la **Ejecución** (qué se envió y a quién).

Se utilizan convenciones compatibles con **Laravel** (snake_case, timestamps) y se estructura para escalar y permitir mantenimiento sin redestiegues constantes.

## 1. Estrategia de Datos

*   **Separación de Responsabilidades:**
    *   `notification_templates`: Define las reglas, textos base y configuración de canales.
    *   `user_notifications`: Almacena el historial inmutable de lo enviado, con el contenido ya renderizado.
*   **Códigos vs IDs:** La lógica de negocio debe referenciar `code` (ej: `BOLETA_CERCA_DE_VENCER`) y nunca IDs numéricos.
*   **Contenido Renderizado:** El historial guarda el mensaje final ("Tu boleta 123 vence mañana") y no la plantilla, para garantizar integridad histórica.

## 2. Estructura de Tablas

### 2.1. Tabla `notification_templates` (Definiciones)
Almacena las plantillas maestras. Permite editar textos y configuraciones sin tocar el código fuente.

| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `BIGINT` (PK) | Identificador interno (Auto-incremental). |
| `code` | `VARCHAR(50)` | **CRÍTICO.** Identificador único lógico (Slug). Usado en el código para disparar la notificación (ej: `BOLETA_CERCA_DE_VENCER`). Unique. |
| `title_template` | `VARCHAR(255)` | Título de la notificación. |
| `body_template` | `TEXT` | Plantilla del cuerpo con placeholders (ej: `Tu boleta "{caratula}" vence mañana.`). |
| `channel_config` | `VARCHAR(100)` | Canales habilitados por defecto. Ej: `push\|mail`. Nullable. |
| `is_active` | `BOOLEAN` | Flag para deshabilitar notificaciones globalmente. Default `true`. |
| `created_at` | `TIMESTAMP` | Fecha de creación. |
| `updated_at` | `TIMESTAMP` | Fecha de última actualización. |

#### Datos Semilla (Seed Data)
Estos registros iniciales cubren los casos de uso definidos. Nótese que el caso 4.3 se divide en dos templates distintos según la lógica de negocio.

```sql
INSERT INTO notification_templates (code, title_template, body_template, channel_config, is_active) VALUES
('RECORDATORIO_MINIMO_CASI_CUBIERTO', '¡Ya estás a un paso!', 'Solo te falta ${monto_faltante} para completar el año.', '["push"]', 1),
('PAGO_CONFIRMADO', '¡Pago confirmado!', 'Tu aporte fue imputado exitosamente. Ya podés visualizarlo en el historial de aportes.', '["push"]', 1),
('BOLETA_POR_VENCER', 'Boleta por vencer', 'Tu boleta "{caratula}" vence mañana. No olvides abonarla para mantener tus aportes al día.', '["push", "mail"]', 1),
('BOLETA_PENDIENTE', 'Boleta pendiente', 'Tenés boletas creadas sin abonar. Recordá que podés realizar el pago desde la app.', '["push"]', 1),
('RECORDATORIO_APORTES', 'Recordatorio de aportes', '¿Todavía no alcanzaste el aporte mínimo anual? Recordá que podés generar nuevas boletas.', '["mail"]', 1);
```

### 2.2. Tabla `user_notifications` (Historial / Ejecución)
Buzón de notificaciones del usuario. Es la fuente de verdad para la UI de la App Móvil.

| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | `BIGINT` (PK) | Identificador interno (Auto-incremental). Rápido. |
| `uuid` | `UUID` | Identificador público único. Seguro, usado en rutas/API. Unique. |
| `user_id` | `BIGINT` (FK) | ID del usuario afiliado. Relación con tabla usuarios. Cascade on delete. |
| `template_id` | `BIGINT` (FK) | Referencia a `notification_templates.id`. Nullable. Null on delete. |
| `title` | `VARCHAR(255)` | Título final generado (Snapshot). |
| `body` | `TEXT` | Mensaje final generado con variables reemplazadas (Snapshot). |
| `data_payload` | `JSON` | **VITAL para Deep Linking.** Datos para la acción al tocar la notificación. Ej: `{"route": "/pagos/detalle", "boleta_id": 1054}`. Nullable. |
| `read_at` | `TIMESTAMP` | Fecha de lectura. `NULL` si no ha sido leída. |
| `sent_at` | `TIMESTAMP` | Fecha de envío. Nullable. |
| `external_id` | `VARCHAR(255)` | ID externo (ej. de Firebase) para trazabilidad. Nullable. |
| `created_at` | `TIMESTAMP` | Fecha de registro. |
| `updated_at` | `TIMESTAMP` | Fecha de actualización. |

**Índices:**
- `['user_id', 'created_at']`
- `['user_id', 'read_at']`

## 3. Lógica de Negocio y Mapeo

### 3.1. Resolución de la Lógica 4.3 (Aportes Mínimos)
El backend no debe decidir qué texto mostrar en la vista, sino qué **evento** ocurrió.

*   **Evento A:** El usuario está cerca de cumplir el aporte (ej. falta menos de $50.000).
    *   Acción: Usar template `RECORDATORIO_MINIMO_CASI_CUBIERTO`.
    *   Variables: `{ "monto_faltante": "$12.500" }`.
*   **Evento B:** El usuario está lejos del objetivo.
    *   Acción: Usar template `RECORDATORIO_APORTES`.
    *   Variables: `{}` (Ninguna).

### 3.2. Estructura del Payload (Deep Linking)
El campo `data_payload` permite que la notificación sea "accionable".

| Tipo de Notificación | Payload JSON Sugerido | Acción en App |
| :--- | :--- | :--- |
| `BOLETA_POR_VENCER` | `{"route": "/boleta-generada", "args": {"boleta_id": 123}}` | Navegar al detalle de la boleta. |
| `BOLETA_PENDIENTE` | `{"route": "/ver-boletas", "filtro_estado": "pendientes"}` | Ir al listado de boletas filtrado. |
| `RECORDATORIO_MINIMO_CASI_CUBIERTO` | `{"route": "/aportes/historial"}` | Ver historial de aportes. |
| `RECORDATORIO_APORTES` | `{"route": "/aportes/historial"}` | Ver historial de aportes. |
| `PAGO_CONFIRMADO` | `{"route": "/aportes/historial"}` | Ver historial de aportes. |

## 4. Principios de Diseño (Correcciones)

1.  **Cero Datos de Usuario en Templates:** Los templates nunca deben contener nombres o datos específicos (ej. "Juan Pérez"). Usar placeholders `"{nombre}"` o `"{caratula}"`.
2.  **Snapshot de Contenido:** `user_notifications` guarda el texto final. Si se decide cambiar el template el historial del usuario no debe cambiar.
3.  **Notificaciones Accionables:** Siempre incluir `data_payload` para dirigir al usuario a la pantalla relevante, no solo abrir la app.
