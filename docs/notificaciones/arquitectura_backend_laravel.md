# Documentación de la Arquitectura: Módulo de Notificaciones - Backend Laravel

Este documento detalla la arquitectura del backend Laravel para el módulo de Notificaciones. La implementación sigue una organización modular que separa las responsabilidades en capas claramente definidas: Domain (Modelos y Servicios), Http (Controladores y Resources), Notifications (Clases de notificación FCM), Jobs (Procesamiento asíncrono) y Console (Comandos artisan y scheduling).

El objetivo del backend es gestionar el envío inteligente de notificaciones push a los afiliados, incluyendo: análisis del estado de cada afiliado para determinar qué notificaciones enviar, sistema de priorización cuando hay múltiples notificaciones candidatas, control de frecuencia de envío mediante cooldowns, registro de dispositivos FCM, y gestión del historial de notificaciones enviadas.

## Capa de Dominio (Domain)

Contiene los modelos Eloquent que representan las entidades de la base de datos y el servicio principal que implementa la lógica de negocio.

### Modelos (Models)

Representan las tablas de la base de datos relacionadas con el módulo de notificaciones.

- `NotificacionAfiliado.php`: Modelo que representa cada notificación enviada a un afiliado, almacenada en la tabla `AFILIADO_NOTIFICACIONES`. Contiene los campos: `naf` (número de afiliado), `template_id` (referencia al template), `title`, `body`, `data_payload`, `sent_at`, `read_at`, `external_id` y `uuid`. Genera automáticamente un UUID único al crear cada registro mediante el evento `creating`. Define una relación `belongsTo` con `NotificacionTemplate` para obtener el tipo de notificación.

- `NotificacionTemplate.php`: Modelo que representa las plantillas de notificación predefinidas, almacenadas en la tabla `NOTIFICACION_TEMPLATES`. Contiene los campos: `code` (identificador único del tipo), `title_template`, `body_template`, `channels` (canales de envío separados por `|`), `priority` y `is_active`. Utiliza Eloquent Accessors para parsear el campo `channels` como array y `is_active` como booleano.

- `DispositivoAfiliado.php`: Modelo que representa los dispositivos registrados para recibir notificaciones push, almacenado en la tabla `AFILIADO_DISPOSITIVOS`. Contiene los campos: `naf` (número de afiliado), `fcm_token` (token de Firebase Cloud Messaging), `nombre_dispositivo`, `plataforma` (Android/iOS) y `last_used_at`.

### Servicios (Services)

Clases que encapsulan la lógica de negocio compleja del módulo.

- `NotificacionesService.php`: Servicio principal que orquesta toda la lógica de análisis y envío de notificaciones. Define constantes de frecuencia para cada tipo de notificación (cooldowns en días) que controlan con qué frecuencia se puede enviar cada tipo de notificación a un mismo afiliado. Incluye los métodos:
  - `analizarEstadoGeneral(Afiliado)`: Analiza el estado completo de un afiliado y determina qué notificación enviar. Evalúa múltiples condiciones (boletas por vencer, boletas pendientes, mínimo casi cubierto, recordatorio de aportes), genera una colección de notificaciones candidatas con sus prioridades, y envía únicamente la de mayor prioridad.
  - `procesarPagosImputados(Afiliado)`: Envía notificación de pagos imputados a un afiliado específico.
  - `checkBoletasPorVencer()`: Verifica si hay boletas próximas a vencer y retorna la primera encontrada.
  - `checkBoletasPendientes()`: Verifica si existen boletas no imputadas y no vencidas.
  - `checkMinimoCasiCubierto()`: Verifica si el porcentaje aportado está entre 75% y 100%.
  - `checkRecordatorioAportes()`: Compara el progreso de aportes con el tiempo transcurrido del año.
  - `shouldSend()`: Determina si una notificación debe enviarse según el cooldown configurado.
  - `logNotification()`: Registra la notificación enviada en la base de datos.

## Capa HTTP (Http)

Maneja las peticiones HTTP entrantes desde la aplicación móvil.

### Controladores (Controllers)

- `NotificacionesController.php`: Controlador que expone los endpoints REST para el módulo. Implementa tres acciones:
  - `registrarDispositivo(Request)`: Registra o actualiza un dispositivo FCM. Valida los campos requeridos (`fcmToken`, `nroAfiliado`, `nombreDispositivo`, `plataforma`) y utiliza `updateOrCreate` para evitar duplicados de token. Endpoint: `POST /api/notificaciones/afiliado/dispositivos/registrar`.
  - `obtenerNotificaciones(string $nroAfiliado)`: Retorna el listado paginado de notificaciones de un afiliado. Utiliza `simplePaginate` con 10 elementos por página y transforma los resultados mediante `NotificacionResource`. Endpoint: `GET /api/notificaciones/afiliado/{nroAfiliado}`.
  - `marcarLeido(Request)`: Marca como leídas las notificaciones cuyos UUIDs se envían en el request. Valida que `uuidList` sea un array de strings y actualiza el campo `read_at` de cada notificación. Endpoint: `POST /api/notificaciones/marcar-leido`.

### Resources

- `NotificacionResource.php`: Transforma el modelo `NotificacionAfiliado` al formato JSON de la API. Retorna los campos: `uuid`, `type` (código del template), `title`, `body`, `sent_at` y `read_at`.

## Capa de Notificaciones (Notifications)

Contiene las clases de notificación que extienden el sistema de notificaciones de Laravel con soporte para Firebase Cloud Messaging.

### Notificación Base

- `GenericNotification.php`: Clase abstracta base para todas las notificaciones del módulo. Implementa `ShouldQueue` para procesamiento asíncrono y utiliza los traits `Queueable` y `SerializesModels`. En el constructor, carga automáticamente el template correspondiente desde la base de datos usando el código constante definido en cada subclase. Provee métodos para obtener el título, cuerpo, ID del template y prioridad desde el template cargado. Define el canal de envío como `FcmChannel` y genera el mensaje FCM con título y cuerpo.

### Notificaciones Específicas

- `BoletaPorVencerNotification.php`: Notificación para boletas próximas a vencer (2 días antes). Recibe una `BoletaGenerada` y reemplaza el placeholder `{caratula}` en el body del template con los datos de la boleta. Envía por dos canales: FCM y email. Implementa `toMail()` para generar un correo electrónico personalizado con saludo, información de la boleta y fecha de vencimiento.

- `BoletasPendientesNotification.php`: Notificación simple que alerta sobre boletas pendientes de pago. Utiliza el template base sin modificaciones.

- `PagosImputadosNotificacion.php`: Notificación que informa al afiliado cuando se han imputado pagos a su cuenta. Utiliza el template base sin modificaciones.

- `RecordatorioAportesNotification.php`: Recordatorio general sobre la necesidad de realizar aportes. Utiliza el template base sin modificaciones.

- `RecordatorioMinimoCasiCubiertoNotification.php`: Notificación que se envía cuando el afiliado ha cubierto entre el 75% y 100% del aporte mínimo. Recibe el porcentaje faltante y calcula el monto faltante basándose en el aporte mínimo vigente. Reemplaza el placeholder `{monto_faltante}` en el body del template.

## Capa de Jobs

Jobs para procesamiento asíncrono mediante colas de Laravel.

- `NotificarAfiliadosGeneralJob.php`: Job diseñado para procesar notificaciones masivas a todos los afiliados elegibles. Obtiene los números de afiliado únicos que tienen dispositivos registrados, filtra por afiliados activos (estado 10) que tienen dispositivos, y procesa en chunks de 100 para evitar problemas de memoria. Para cada afiliado, invoca `NotificacionesService.analizarEstadoGeneral()`.

- `NotificarPagosImputadosJob.php`: Job que procesa la notificación de pagos imputados para un afiliado específico. Recibe una instancia de `Afiliado` y delega al servicio `procesarPagosImputados()`.

## Capa de Consola (Console)

Comandos artisan y configuración del scheduler.

### Comandos (Commands)

- `TriggerNotificacionesGenerales.php`: Comando artisan que despacha el job de notificaciones generales. Signature: `afiliados:notificar`. Simplemente despacha `NotificarAfiliadosGeneralJob` a la cola.

- `TriggerNotificacionesPagosImputados.php`: Comando artisan que busca afiliados con movimientos acreditados en el día actual y despacha jobs individuales para notificarlos. Signature: `afiliados:notificar-pagos-imputados`. Filtra afiliados que tienen dispositivos registrados y movimientos con `fecha_acreditacion` igual a hoy, procesando en chunks de 100.

### Kernel (Scheduling)

- `Kernel.php`: Configura la programación de tareas automáticas:
  - `afiliados:notificar`: Se ejecuta diariamente a las 08:00 AM para analizar y enviar notificaciones generales.
  - `afiliados:notificar-pagos-imputados`: Se ejecuta diariamente a las 21:00 PM para notificar pagos imputados del día.
  - Ambos comandos registran su salida en `storage/logs/scheduler-output.log`.

## Flujo de Datos: Envío de Notificaciones Generales

Para ilustrar cómo interactúan las capas, se describe el flujo de envío de notificaciones generales:

1. **Scheduler**: A las 08:00 AM, el scheduler de Laravel ejecuta el comando `afiliados:notificar`.

2. **Console -> Jobs**: El comando `TriggerNotificacionesGenerales` despacha `NotificarAfiliadosGeneralJob` a la cola.

3. **Jobs**: El worker de la cola procesa el job, que obtiene todos los afiliados activos con dispositivos registrados.

4. **Jobs -> Domain**: Para cada afiliado (en chunks de 100), el job invoca `NotificacionesService.analizarEstadoGeneral()`.

5. **Domain**: El servicio carga las boletas del afiliado y evalúa múltiples condiciones:
   - ¿Tiene boletas por vencer en los próximos 2 días?
   - ¿Tiene boletas pendientes de pago?
   - ¿Ha cubierto entre 75% y 100% del aporte mínimo?
   - ¿Su progreso de aportes está retrasado respecto al tiempo del año?

6. **Domain**: Para cada condición que se cumple, verifica el cooldown consultando la última notificación del mismo tipo enviada al afiliado en `NotificacionAfiliado`.

7. **Domain**: Genera una colección de notificaciones candidatas con sus prioridades y selecciona la de mayor prioridad.

8. **Domain -> Notifications**: Instancia la clase de notificación correspondiente y la envía mediante `$afiliado->notify()`.

9. **Notifications**: Laravel procesa la notificación y la envía por `FcmChannel` (y opcionalmente por email si está configurado).

10. **Domain**: El servicio registra la notificación enviada en `NotificacionAfiliado` con todos sus datos.

## Flujo de Datos: Registro de Dispositivo

1. **Aplicación Móvil**: Al iniciar la app, obtiene el token FCM y los datos del dispositivo.

2. **Http**: La app envía un POST a `/api/notificaciones/afiliado/dispositivos/registrar` con los datos.

3. **Http**: `NotificacionesController.registrarDispositivo()` valida los datos requeridos.

4. **Http -> Domain**: El controlador utiliza `DispositivoAfiliado::updateOrCreate()` para registrar o actualizar el dispositivo.

5. **Domain**: Si el token ya existe, actualiza los datos del dispositivo; si no, crea un nuevo registro.

6. **Http**: Retorna respuesta JSON confirmando el registro exitoso.

## Flujo de Datos: Obtención de Notificaciones

1. **Aplicación Móvil**: Solicita GET a `/api/notificaciones/afiliado/{nroAfiliado}`.

2. **Http**: `NotificacionesController.obtenerNotificaciones()` consulta las notificaciones del afiliado.

3. **Http -> Domain**: Utiliza `NotificacionAfiliado::where('naf', $nroAfiliado)` con eager loading del template.

4. **Domain**: Eloquent retorna los resultados paginados (10 por página).

5. **Http**: `NotificacionResource` transforma cada modelo al formato JSON de la API.

6. **Aplicación Móvil**: Recibe el listado paginado con los datos de cada notificación.

## Características Especiales del Módulo

### Sistema de Priorización Inteligente

El servicio implementa un sistema de priorización que:
- Evalúa múltiples condiciones de notificación para cada afiliado
- Asigna prioridades definidas en los templates de la base de datos
- Envía únicamente la notificación de mayor prioridad para evitar bombardear al usuario
- Permite configurar prioridades sin cambios de código

### Control de Frecuencia (Cooldowns)

Sistema de cooldowns que previene el envío excesivo:
- `BOLETA_POR_VENCER`: Cada 2 días
- `BOLETAS_PENDIENTES`: Cada 3 días
- `RECORDATORIO_APORTES`: Cada 7 días
- `PAGOS_IMPUTADOS`: Sin restricción (siempre se puede enviar)
- `MINIMO_CASI_CUBIERTO`: Cada 7 días

### Templates Dinámicos

Los templates de notificación están almacenados en base de datos, permitiendo:
- Modificar títulos y mensajes sin deploy
- Soporte para placeholders dinámicos (`{caratula}`, `{monto_faltante}`)
- Activación/desactivación de tipos de notificación
- Configuración de prioridades por tipo

### Procesamiento Asíncrono

Todas las notificaciones se procesan mediante colas:
- Los jobs utilizan chunks para procesar grandes volúmenes de afiliados
- Las notificaciones implementan `ShouldQueue` para no bloquear el proceso principal
- El scheduler programa las tareas en horarios específicos

### Integración con Firebase Cloud Messaging

El módulo utiliza el paquete `laravel-notification-channels/fcm`:
- Canal FCM configurado como canal de envío principal
- Soporte para notificaciones con título y cuerpo
- Posibilidad de agregar canales adicionales (email) por tipo de notificación

### Análisis Inteligente del Porcentaje de Aportes

El servicio implementa lógica inteligente para recordatorios:
- Compara el porcentaje aportado con el tiempo transcurrido del año
- Usa un threshold de 15% de diferencia para determinar si el afiliado está atrasado
- Notifica cuando el afiliado está cerca de cumplir el mínimo (75-100%)

