# Documentación de la Arquitectura: Módulo de Notificaciones

Este documento detalla la arquitectura específica del módulo de Notificaciones. La implementación se adhiere a los principios de Arquitectura Limpia (Clean Architecture) definidos en la [documentación de la arquitectura general](/docs/arquitectura_general.md), organizando el código en las capas de Presentación, Dominio y Datos.

El objetivo de este módulo es gestionar todos los aspectos relacionados con las notificaciones push: registro de dispositivos para recibir notificaciones, obtención del listado de notificaciones del usuario, marcado de notificaciones como leídas, y manejo de notificaciones en tiempo real mediante Firebase Cloud Messaging (FCM).

## Capa de Presentación (Presentation)

Es la responsable de la interfaz de usuario (UI) y la gestión del estado local de la misma. Se comunica con la capa de Dominio a través de **Providers** para ejecutar acciones y reaccionar a los cambios de estado.

### Componentes Principales de la Capa de Presentación

#### Vistas (Screens/Widgets)

Son los componentes visuales con los que el usuario interactúa.

- `notificaciones_screen.dart`: Pantalla principal del módulo de notificaciones que muestra el listado paginado de todas las notificaciones del usuario. Incluye funcionalidades como: visualización de notificaciones leídas y no leídas con diferenciación visual, contador de notificaciones sin leer, pull-to-refresh para actualizar el listado, detalle de notificación mediante modal bottom sheet, y soporte para diferentes tipos de notificaciones con iconos y colores distintivos (éxito, advertencia, información, recordatorio). Implementa formato de fecha relativa (hace X minutos/horas/días) y manejo de estados vacíos y de error.

#### Gestores de Estado (Providers)

Se utiliza `Riverpod` para la gestión de estado y la inyección de dependencias. Los providers orquestan las interacciones del usuario, llaman a los casos de uso de la capa de Dominio y exponen el estado a la UI.

- `notification_providers.dart`: Centraliza la inyección de dependencias para todo el módulo de notificaciones, incluyendo la configuración de casos de uso y notifiers. Define los providers para `RegistrarDispositivoUseCase`, `ObtenerListadoNotificacionesUseCase`, `MarcarNotificacionesLeidasUseCase` y `NotificacionesNotifier`.

- `notificaciones_notifier.dart`: Gestiona el estado completo del listado de notificaciones (`NotificacionesState`). Maneja la obtención del listado de notificaciones desde el backend, actualización automática del estado local después de marcar notificaciones como leídas, y transformación de notificaciones no leídas a leídas en el estado local. Utiliza `AsyncNotifier` para manejar estados de carga, éxito y error de forma reactiva.

- `fcm_notifications_notifier.dart`: Administra la inicialización y configuración de Firebase Cloud Messaging. Se encarga de solicitar permisos de notificaciones al usuario, obtener y registrar el token FCM del dispositivo en el backend, configurar listeners para notificaciones recibidas en primer plano (`onMessage`) y notificaciones que abren la aplicación (`onMessageOpenedApp`), y manejo de suscripciones a topics de Firebase. Este notifier se inicializa automáticamente al iniciar la aplicación.

## Capa de Dominio (Domain)

Contiene la lógica de negocio pura del módulo de notificaciones, sin depender de ninguna implementación externa (UI o base de datos).

### Componentes Principales de la Capa de Dominio

#### Entidades (Entities)

Representan los objetos de negocio centrales.

- `notificacion_entity.dart`: Modela una notificación en el contexto de la aplicación, conteniendo los datos esenciales: UUID único de la notificación, título, mensaje, código de tipo (que determina el tipo visual de la notificación), fecha de envío, fecha de lectura (opcional), y datos adicionales opcionales. Incluye una propiedad computada `leido` que retorna `true` si la notificación tiene fecha de lectura asignada.

#### Repositorios (Interfaces Abstractas)

Definen los contratos que la capa de Datos debe implementar. Describen qué se puede hacer, pero no cómo.

- `notificaciones_repository.dart`: Define la interfaz para las operaciones relacionadas con notificaciones del backend. Incluye métodos para: `obtenerNotificaciones` que retorna un listado paginado de notificaciones para un número de afiliado, `registrarDispositivo` para registrar un dispositivo con su token FCM asociado a un afiliado, y `marcarNotificacionesComoLeidas` para actualizar el estado de lectura de múltiples notificaciones mediante sus UUIDs.

- `firebase_notification_repository.dart`: Define la interfaz para las operaciones relacionadas con Firebase Cloud Messaging. Incluye métodos para: `initialize` para inicializar y solicitar permisos de FCM, `getToken` para obtener el token FCM del dispositivo, `onMessage` como Stream para recibir notificaciones en primer plano, `onMessageOpenedApp` como Stream para recibir notificaciones que abren la aplicación, y métodos para suscribirse y desuscribirse de topics (`subscribeToTopic`, `unsubscribeFromTopic`).

#### Casos de Uso (Use Cases)

Encapsulan una única regla de negocio o una tarea específica. Son invocados por los **Providers** de la capa de Presentación.

- `obtener_listado_notificaciones_usecase.dart`: Orquesta la lógica para obtener el listado de notificaciones del usuario autenticado. Valida que exista un usuario autenticado obteniendo su número de afiliado desde el repositorio de usuarios, y luego delega la obtención de notificaciones al repositorio de notificaciones.

- `marcar_notificaciones_leidas_usecase.dart`: Maneja la lógica para marcar notificaciones como leídas. Obtiene el usuario autenticado para validar su existencia y extraer el número de afiliado, y luego delega la operación de marcado al repositorio de notificaciones pasando la lista de UUIDs.

- `registrar_dispositivo_usecase.dart`: Coordina el registro de un dispositivo para recibir notificaciones push. Obtiene el usuario autenticado para validar su existencia y extraer el número de afiliado, detecta la plataforma del dispositivo (Android/iOS) y obtiene el nombre del dispositivo usando `DeviceInfoPlugin`, y finalmente registra el dispositivo con el token FCM, número de afiliado, nombre del dispositivo y plataforma en el backend.

## Capa de Datos (Data)

Implementa los repositorios definidos en la capa de Dominio. Es la responsable de obtener los datos de las fuentes correspondientes (API externa de notificaciones y Firebase Cloud Messaging) y de transformar esos datos en las Entidades que el Dominio entiende.

### Componentes Principales de la Capa de Datos

#### Repositorios (Implementaciones)

Clases concretas que implementan las interfaces de la capa de Dominio.

- `notificaciones_repository_impl.dart`: Implementación de `NotificacionesRepository`. Delega las operaciones al `NotificacionesDataSource` y maneja la obtención del token de autenticación JWT mediante `JwtTokenService` para todas las peticiones HTTP. Transforma los modelos recibidos del datasource en entidades del dominio, especialmente en el método `obtenerNotificaciones` donde convierte `NotificacionModel` a `NotificacionEntity` usando el método `toEntity()`.

- `firebase_notification_repository_impl.dart`: Implementación de `FirebaseNotificationRepository`. Encapsula todas las operaciones con Firebase Cloud Messaging usando `FirebaseMessaging`. Maneja la inicialización con solicitud de permisos y configuración de opciones de presentación para notificaciones en primer plano, obtención del token FCM, y exposición de streams para notificaciones recibidas. También implementa la suscripción y desuscripción a topics de Firebase.

#### Fuentes de Datos (Data Sources)

Clases que interactúan directamente con una única fuente de datos.

- `notificaciones_data_source.dart`: Responsable de toda la comunicación con la API REST del backend para operaciones de notificaciones. Maneja peticiones HTTP para: registro de dispositivos mediante POST a `/api/notificaciones/afiliado/dispositivos/registrar`, marcado de notificaciones como leídas mediante POST a `/api/notificaciones/marcar-leido`, y obtención de notificaciones mediante GET a `/api/notificaciones/afiliado/{nroAfiliado}`. Todas las peticiones incluyen el token de autenticación JWT en los headers. Parseo de respuestas JSON en modelos correspondientes, especialmente el parseo de respuestas paginadas en `obtenerNotificaciones`.

#### Modelos (Models)

Representan la estructura de los datos tal como se reciben de la API. Incluyen métodos `fromJson` para el parseo de las respuestas JSON y `toEntity` para la transformación a entidades del dominio.

- `notificacion_model.dart`: Modelo que encapsula los datos de una notificación tal como se reciben del backend: UUID, tipo, título, cuerpo del mensaje, fecha de envío (`sent_at`) y fecha de lectura opcional (`read_at`). Incluye método `fromJson` para parsear respuestas JSON del API y método `toEntity` para transformar el modelo en `NotificacionEntity` del dominio, mapeando los campos del modelo a los campos de la entidad.

#### Mapeadores (Mappers)

Las transformaciones de modelos a entidades se realizan principalmente dentro de los repositorios y mediante métodos `toEntity` en los modelos, manteniendo la lógica de mapeo cercana a donde se utilizan los datos. Los modelos incluyen métodos `fromJson` y `toEntity` para facilitar la serialización y transformación.

## Flujo de datos: ejemplo de Obtención de Notificaciones

Para ilustrar cómo interactúan las capas, a continuación se describe el flujo de obtención del listado de notificaciones:

1. **Presentación**: el usuario navega a la pantalla `notificaciones_screen.dart` o realiza pull-to-refresh en el listado.

2. **Presentación**: en el `initState` o al activar el refresh, se invoca `obtenerListadoNotificaciones()` en el `NotificacionesNotifier`.

3. **Presentación**: el `NotificacionesNotifier` actualiza su estado a `AsyncValue.loading()` para mostrar indicador de carga en la UI.

4. **Presentación -> Dominio**: el `NotificacionesNotifier` invoca al `ObtenerListadoNotificacionesUseCase.execute()`.

5. **Dominio**: el `ObtenerListadoNotificacionesUseCase` obtiene el usuario actual desde el `UsuarioRepository` para validar autenticación y extraer el número de afiliado.

6. **Dominio**: si el usuario existe, el caso de uso llama al método `obtenerNotificaciones` del `NotificacionesRepository` (la interfaz) pasando el número de afiliado.

7. **Dominio -> Datos**: la inyección de dependencias provee la implementación `NotificacionesRepositoryImpl`, que recibe la llamada.

8. **Datos**: `NotificacionesRepositoryImpl` obtiene el token JWT de autenticación mediante `JwtTokenService.obtenerToken()`.

9. **Datos**: `NotificacionesRepositoryImpl` delega la operación al `NotificacionesDataSource.obtenerNotificaciones()` pasando el número de afiliado y el token.

10. **Datos**: `NotificacionesDataSource` ejecuta la petición GET a la API del backend con el token en los headers. Si es exitosa (código 200), parsea la respuesta JSON paginada en un `PaginatedResponse<NotificacionModel>`.

11. **Datos**: el datasource retorna el `PaginatedResponse<NotificacionModel>` al repositorio.

12. **Datos -> Dominio**: `NotificacionesRepositoryImpl` transforma cada `NotificacionModel` en `NotificacionEntity` usando el método `toEntity()`, creando un nuevo `PaginatedResponse<NotificacionEntity>` con los datos transformados pero manteniendo los metadatos de paginación (links y meta).

13. **Dominio -> Presentación**: El `ObtenerListadoNotificacionesUseCase` retorna el `PaginatedResponse<NotificacionEntity>` al `NotificacionesNotifier`.

14. **Presentación**: el `NotificacionesNotifier` detecta automáticamente las notificaciones no leídas y llama internamente a `_marcarNotificacionesComoLeidas()` para marcarlas como leídas en el backend.

15. **Presentación**: después de marcar como leídas, el notifier actualiza el estado local de las notificaciones, asignando `fechaLeido: DateTime.now()` a las notificaciones que fueron marcadas.

16. **Presentación**: el `NotificacionesNotifier` actualiza su estado a `AsyncValue.data()` con el `NotificacionesState` actualizado. La UI reacciona a este cambio y muestra el listado de notificaciones con las actualizaciones de estado de lectura.

## Flujo de datos: ejemplo de Registro de Dispositivo

Para ilustrar el flujo de registro de dispositivo para recibir notificaciones push:

1. **Presentación**: al iniciar la aplicación, el `FcmNotificationNotifier` se inicializa automáticamente mediante su provider.

2. **Presentación**: el `FcmNotificationNotifier` invoca `_initialize()` en su método `build()`.

3. **Presentación -> Dominio**: el notifier llama a `FirebaseNotificationRepository.initialize()` para solicitar permisos de notificaciones.

4. **Dominio -> Datos**: la implementación `FirebaseNotificationRepositoryImpl` solicita permisos al usuario mediante `FirebaseMessaging.requestPermission()` y configura las opciones de presentación para notificaciones en primer plano.

5. **Datos -> Dominio -> Presentación**: una vez inicializado, el notifier obtiene el token FCM llamando a `FirebaseNotificationRepository.getToken()`.

6. **Presentación**: si el token existe, el notifier invoca al `RegistrarDispositivoUseCase.execute(token)`.

7. **Presentación -> Dominio**: el `RegistrarDispositivoUseCase` obtiene el usuario actual desde el `UsuarioRepository` para validar autenticación y extraer el número de afiliado.

8. **Dominio**: el caso de uso detecta la plataforma del dispositivo (Android/iOS) usando `DeviceInfoPlugin` y obtiene el nombre del dispositivo (modelo en Android, nombre en iOS).

9. **Dominio**: el caso de uso llama al método `registrarDispositivo` del `NotificacionesRepository` pasando el token FCM, número de afiliado, nombre del dispositivo y plataforma.

10. **Dominio -> Datos**: `NotificacionesRepositoryImpl` obtiene el token JWT y delega al `NotificacionesDataSource.registrarDispositivo()`.

11. **Datos**: `NotificacionesDataSource` ejecuta la petición POST a `/api/notificaciones/afiliado/dispositivos/registrar` con los datos del dispositivo y el token de autenticación.

12. **Datos -> Dominio -> Presentación**: si el registro es exitoso (código 200), el flujo retorna sin errores y el dispositivo queda registrado para recibir notificaciones push.

13. **Presentación**: el `FcmNotificationNotifier` configura los listeners para notificaciones recibidas (`onMessage`) y notificaciones que abren la aplicación (`onMessageOpenedApp`), preparando la aplicación para manejar notificaciones en tiempo real.

## Flujo de datos: ejemplo de Marcado de Notificaciones como Leídas

Para ilustrar el flujo automático de marcado de notificaciones como leídas:

1. **Presentación**: después de obtener el listado de notificaciones, el `NotificacionesNotifier` detecta automáticamente las notificaciones no leídas en el método `_marcarNotificacionesComoLeidas()`.

2. **Presentación**: si hay notificaciones no leídas, el notifier extrae sus UUIDs y invoca al `MarcarNotificacionesLeidasUseCase.execute(uuidList)`.

3. **Presentación -> Dominio**: el `MarcarNotificacionesLeidasUseCase` obtiene el usuario actual desde el `UsuarioRepository` para validar autenticación y extraer el número de afiliado.

4. **Dominio**: el caso de uso llama al método `marcarNotificacionesComoLeidas` del `NotificacionesRepository` pasando la lista de UUIDs y el número de afiliado.

5. **Dominio -> Datos**: `NotificacionesRepositoryImpl` obtiene el token JWT y delega al `NotificacionesDataSource.marcarNotificacionesComoLeidas()`.

6. **Datos**: `NotificacionesDataSource` ejecuta la petición POST a `/api/notificaciones/marcar-leido` con la lista de UUIDs y el número de afiliado, incluyendo el token de autenticación en los headers.

7. **Datos -> Dominio -> Presentación**: si el marcado es exitoso (código 200), el flujo retorna sin errores.

8. **Presentación**: el `NotificacionesNotifier` actualiza el estado local de las notificaciones, creando nuevas instancias de `NotificacionEntity` con `fechaLeido: DateTime.now()` para las notificaciones marcadas como leídas.

9. **Presentación**: el estado se actualiza con las notificaciones modificadas y la UI reacciona mostrando las notificaciones como leídas (sin el indicador visual de no leídas y con estilo visual diferente).

## Características Especiales del Módulo

### Integración con Firebase Cloud Messaging

El módulo está diseñado con una arquitectura flexible que separa las responsabilidades de Firebase:

- **FirebaseNotificationRepository**: Abstrae todas las operaciones con FCM, permitiendo cambiar la implementación sin afectar el resto del módulo
- **Inicialización automática**: El dispositivo se registra automáticamente al iniciar la aplicación
- **Manejo de permisos**: Solicita permisos de notificaciones de forma transparente al usuario
- **Streams reactivos**: Expone streams para notificaciones recibidas en primer plano y notificaciones que abren la aplicación

### Gestión de Estado Reactiva

Utiliza un patrón de estado inmutable con `AsyncNotifier`:

- `NotificacionesState`: incluye el listado paginado de notificaciones con metadatos de paginación
- Estados asíncronos: Loading, Success (con datos) y Error (con mensaje de error)
- Actualización automática: Las notificaciones se marcan como leídas automáticamente al obtenerlas
- Transformación de estado local: Actualiza el estado local después de operaciones exitosas sin necesidad de recargar desde el backend

### Paginación de Notificaciones

El módulo soporta paginación completa:

- `PaginatedResponse`: Estructura genérica que incluye datos, links de paginación y metadatos
- Metadatos de paginación: Incluye información sobre página actual, total de páginas, elementos por página
- Links de navegación: Proporciona URLs para primera, última, siguiente y página anterior
- Transformación preservada: Los metadatos de paginación se mantienen al transformar modelos a entidades

### Detección Automática de Plataforma

Para el registro de dispositivos:

- Detección de plataforma: Identifica automáticamente si el dispositivo es Android o iOS
- Obtención de información del dispositivo: Usa `DeviceInfoPlugin` para obtener el nombre/modelo del dispositivo
- Manejo de plataformas desconocidas: Proporciona valores por defecto para plataformas no reconocidas

### Visualización Diferenciada por Tipo

La UI adapta la presentación según el tipo de notificación:

- Tipos soportados: Éxito, Advertencia, Información, Recordatorio
- Iconos distintivos: Cada tipo tiene un icono asociado
- Colores temáticos: Cada tipo tiene un color distintivo para mejor identificación visual
- Mapeo flexible: El código de tipo del backend se mapea a tipos visuales mediante función de transformación

### Manejo de Fechas Relativas

Mejora la experiencia de usuario con formato de fecha inteligente:

- Formato relativo: Muestra "Hace X minutos/horas/días" para fechas recientes
- Formato absoluto: Muestra fecha completa para notificaciones antiguas (más de 7 días)
- Localización: Usa `DateFormat` de `intl` para formateo consistente

### Separación de Responsabilidades

Cada aspecto del módulo tiene su propio conjunto de componentes:

- **Notificaciones del backend**: Datasource, Repository y Use Cases específicos para operaciones con la API REST
- **Firebase Cloud Messaging**: Repository separado para todas las operaciones con FCM
- **Gestión de estado**: Notifiers separados para listado de notificaciones y configuración de FCM
- **UI**: Pantalla dedicada con widgets especializados para mostrar notificaciones

Esta separación facilita el mantenimiento, testing y la evolución independiente de cada funcionalidad sin afectar las demás.

