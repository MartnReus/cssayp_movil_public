# Documentación de la Arquitectura: Módulo de Comprobantes

Este documento detalla la arquitectura específica del módulo de Comprobantes. La implementación se adhiere a los principios de Arquitectura Limpia (Clean Architecture) definidos en la [documentación de la arquitectura general](/docs/arquitectura_general.md), organizando el código en las capas de Presentación, Dominio y Datos.

El objetivo de este módulo es gestionar la visualización, generación, descarga y compartición de comprobantes de pago de boletas. Los comprobantes pueden ser de dos tipos: comprobantes de boletas de inicio y comprobantes de boletas de finalización, cada uno con su formato y estructura específica.

## Capa de Presentación (Presentation)

Es la responsable de la interfaz de usuario (UI) y la gestión del estado local de la misma. Se comunica con la capa de Dominio a través de **Providers** para ejecutar acciones y reaccionar a los cambios de estado.

### Componentes Principales de la Capa de Presentación

#### Vistas (Screens/Widgets)

Son los componentes visuales con los que el usuario interactúa.

- `comprobante_inicio_screen.dart`: Pantalla que muestra el detalle completo de un comprobante de pago para boletas de inicio. Presenta los datos del afiliado, información de la boleta única de iniciación de juicio (carátula, tipo de juicio, importe), detalle del pago (identificador, fecha, medio de pago) y el total abonado. Incluye opciones para descargar el comprobante en PDF o compartirlo.

- `comprobante_fin_screen.dart`: Pantalla que muestra el detalle completo de un comprobante de pago para boletas de finalización. Similar a la pantalla de inicio, pero adaptada para mostrar múltiples boletas de finalización con su distribución de montos por organismo y circunscripción. Presenta los datos del afiliado, lista de boletas de finalización pagadas (con carátula, código MVC, tipo de juicio y distribución de montos), detalle del pago y total abonado. Incluye opciones para descargar y compartir.

#### Gestores de Estado (Providers)

Se utiliza `Riverpod` para la gestión de estado y la inyección de dependencias. Los providers orquestan las interacciones del usuario, llaman a los casos de uso de la capa de Dominio y exponen el estado a la UI.

- `comprobantes_providers.dart`: Centraliza la inyección de dependencias para todo el módulo de comprobantes. Configura los providers para los casos de uso de compartir, descargar, generar y obtener comprobantes, conectando la capa de presentación con la de dominio.

- `comprobantes_notifier.dart`: Gestiona el estado del módulo de comprobantes (`ComprobantesState`). Mantiene la entidad del comprobante actual y coordina la obtención de datos de comprobantes desde el repositorio a través del caso de uso correspondiente. Utiliza `AsyncNotifier` para manejar estados de carga y error.

## Capa de Dominio (Domain)

Contiene la lógica de negocio pura del módulo de comprobantes, sin depender de ninguna implementación externa (UI o base de datos).

### Componentes Principales de la Capa de Dominio

#### Entidades (Entities)

Representan los objetos de negocio centrales.

- `comprobante_entity.dart`: Modela un comprobante de pago con todos sus atributos: ID del comprobante, fecha de pago, importe total, lista de boletas pagadas (cada una con su ID, importe, carátula, código MVC, tipo de juicio y distribución de montos por organismo), ID de referencia externa, enlace al comprobante y método de pago utilizado. Esta entidad es la representación central del dominio para los comprobantes.

#### Repositorios (Interfaces Abstractas)

Definen los contratos que la capa de Datos debe implementar. Describen qué se puede hacer, pero no cómo.

- `comprobantes_repository.dart`: Define la interfaz del repositorio de comprobantes con la operación principal `obtenerComprobante` que recibe un ID de boleta pagada y retorna la entidad del comprobante correspondiente.

#### Casos de Uso (Use Cases)

Encapsulan una única regla de negocio o una tarea específica. Son invocados por los **Providers** de la capa de Presentación.

- `obtener_comprobante_usecase.dart`: Caso de uso simple que orquesta la obtención de un comprobante desde el repositorio. Recibe un ID de boleta pagada y retorna la entidad del comprobante correspondiente.

- `generar_comprobante_usecase.dart`: Caso de uso responsable de generar un comprobante en formato PDF. Obtiene el usuario autenticado actual para incluir sus datos en el comprobante, utiliza el servicio de PDF para generar el documento con la información del comprobante y del usuario, y retorna la ruta del archivo PDF generado.

- `descargar_comprobante_usecase.dart`: Maneja la lógica de descarga del comprobante al dispositivo. Primero genera el PDF del comprobante, luego solicita los permisos necesarios de almacenamiento según la plataforma (Android requiere permisos de storage), guarda el archivo en la ubicación apropiada según el sistema operativo (Android: carpeta Downloads, iOS: directorio de documentos de la app, Desktop: carpeta Descargas del usuario), y finalmente intenta abrir el archivo automáticamente. Retorna la ruta final donde se guardó el archivo.

- `compartir_comprobante_usecase.dart`: Gestiona la compartición del comprobante a través de las opciones nativas del sistema operativo. Genera el PDF del comprobante y utiliza la biblioteca `share_plus` para abrir el diálogo de compartir nativo con el archivo PDF adjunto, permitiendo al usuario elegir la aplicación destino (email, WhatsApp, etc.).

## Capa de Datos (Data)

Implementa los repositorios definidos en la capa de Dominio. Es la responsable de obtener los datos de las fuentes correspondientes (API REST) y de transformar esos datos en las Entidades que el Dominio entiende.

### Componentes Principales de la Capa de Datos

#### Repositorios (Implementaciones)

Clases concretas que implementan las interfaces de la capa de Dominio.

- `comprobantes_repository_impl.dart`: Implementación de `ComprobantesRepository`. Coordina las operaciones entre el datasource remoto y local. Para obtener un comprobante, consulta el datasource remoto, maneja las respuestas exitosas y de error, transforma el modelo de datos en la entidad de dominio utilizando el método `toEntity()` del modelo, y lanza excepciones apropiadas en caso de error.

#### Fuentes de Datos (Data Sources)

Clases que interactúan directamente con una única fuente de datos.

- `comprobantes_remote_data_source.dart`: Responsable de toda la comunicación con la API REST para obtener datos de comprobantes. Realiza peticiones GET al endpoint `/api/checkout/datosComprobante/:idBoleta`, maneja diferentes códigos de respuesta HTTP (200 para éxito, otros para errores), parsea respuestas JSON en modelos de datos, y gestiona excepciones de red como `SocketException`, `TimeoutException` y `FormatException`, retornando respuestas de error genéricas en estos casos.

- `comprobantes_local_data_source.dart`: Fuente de datos local preparada para futuras implementaciones de caché de comprobantes. Actualmente configurada con acceso a `DatabaseHelper` pero sin funcionalidad implementada, lista para agregar almacenamiento local si se requiere soporte offline.

#### Modelos (Models)

Representan la estructura de los datos tal como se reciben de la API. Incluyen métodos `fromJson` para el parseo de las respuestas JSON.

- `datos_comprobante_model.dart`: Contiene la jerarquía de modelos para respuestas de comprobantes:
  - `DatosComprobanteResponse`: Clase sealed base para todas las respuestas de comprobantes, conteniendo el código de estado HTTP.
  - `DatosComprobanteSuccessResponse`: Modelo para respuestas exitosas que incluye todos los campos del comprobante (id, fecha, importe, boletas pagadas con su distribución de montos, referencia externa, enlace y método de pago). Incluye el método `toEntity()` para transformar el modelo en `ComprobanteEntity`.
  - `DatosComprobanteGenericErrorResponse`: Modelo para respuestas de error que incluye el mensaje de error descriptivo.

- `typedefs.dart`: Define tipos personalizados usando records de Dart para estructuras de datos específicas:
  - `BoletaPagada`: Record que representa una boleta pagada con sus campos (id, importe, carátula, MVC, tipo de juicio y lista de montos por organismo).
  - `MontoOrganismo`: Record que representa la distribución de un monto específico con circunscripción, organismo y monto numérico.

#### Mapeadores (Mappers)

Las transformaciones de modelos a entidades se realizan principalmente dentro de los modelos mismos. `DatosComprobanteSuccessResponse` incluye el método `toEntity()` que transforma el modelo de datos en `ComprobanteEntity`, manteniendo la lógica de mapeo encapsulada en la capa de datos.

## Flujo de datos: ejemplo de Visualización de Comprobante

Para ilustrar cómo interactúan las capas, a continuación se describe el flujo completo de visualización de un comprobante:

1. **Presentación**: el usuario selecciona una boleta pagada desde el historial o desde la pantalla de pago exitoso y presiona el botón para ver el comprobante.

2. **Presentación**: se navega a `comprobante_inicio_screen.dart` o `comprobante_fin_screen.dart` según el tipo de boleta, pasando el ID de la boleta pagada como parámetro.

3. **Presentación -> Dominio**: el `ComprobantesNotifier` invoca el método `obtenerComprobante` con el ID de la boleta pagada.

4. **Presentación**: el notifier actualiza el estado a `AsyncValue.loading()` para mostrar indicador de carga en la UI.

5. **Presentación -> Dominio**: el notifier llama al `ObtenerComprobanteUseCase.execute` con el ID de boleta.

6. **Dominio -> Datos**: el caso de uso invoca al método `obtenerComprobante` del `ComprobantesRepository` (interfaz).

7. **Datos**: `ComprobantesRepositoryImpl` recibe la llamada y delega al `ComprobantesRemoteDataSource`.

8. **Datos**: `ComprobantesRemoteDataSource` ejecuta una petición GET al endpoint de la API con el ID de boleta.

9. **Datos**: Si la respuesta es exitosa (código 200), el datasource parsea el JSON en un `DatosComprobanteSuccessResponse`. Si hay error de red o timeout, retorna un `DatosComprobanteGenericErrorResponse`.

10. **Datos**: `ComprobantesRepositoryImpl` recibe la respuesta. Si es un error genérico, lanza una excepción con el mensaje de error.

11. **Datos**: Si es exitoso, el repositorio llama al método `toEntity()` del modelo para transformarlo en `ComprobanteEntity`.

12. **Datos -> Dominio**: `ComprobantesRepositoryImpl` retorna la `ComprobanteEntity` al caso de uso.

13. **Dominio -> Presentación**: El `ObtenerComprobanteUseCase` retorna la entidad al `ComprobantesNotifier`.

14. **Presentación**: El notifier actualiza su estado con el comprobante recibido usando `copyWith`. El estado cambia a `AsyncValue.data()` con el `ComprobantesState` actualizado.

15. **Presentación**: La UI detecta el cambio de estado y renderiza la pantalla del comprobante con toda la información: datos del usuario (nombre y número de afiliado), detalles de las boletas pagadas, información del pago y total abonado.

## Flujo de datos: ejemplo de Descarga de Comprobante

Para ilustrar el flujo de descarga y generación de PDF:

1. **Presentación**: el usuario está visualizando un comprobante en `comprobante_inicio_screen.dart` o `comprobante_fin_screen.dart` y presiona el botón "Descargar".

2. **Presentación**: la pantalla establece `_isDownloading = true` para mostrar un indicador de carga y deshabilitar el botón.

3. **Presentación -> Dominio**: se invoca al `DescargarComprobanteUseCase.execute` pasando la entidad `ComprobanteEntity` actual.

4. **Dominio**: el `DescargarComprobanteUseCase` primero llama al `GenerarComprobanteUseCase.execute` con el comprobante.

5. **Dominio**: `GenerarComprobanteUseCase` obtiene el usuario actual a través del `UsuarioRepository.obtenerUsuarioActual()`. Si no hay usuario autenticado, lanza una excepción.

6. **Dominio -> Servicios**: con el usuario obtenido, el caso de uso invoca al `PdfService.generarPdfComprobante` pasando el comprobante y los datos del usuario.

7. **Servicios**: el `PdfService` genera el documento PDF con el formato apropiado según el tipo de comprobante, incluyendo todos los datos necesarios, y guarda el archivo en el directorio temporal de la aplicación.

8. **Servicios -> Dominio**: el servicio retorna la ruta del archivo PDF generado al `GenerarComprobanteUseCase`.

9. **Dominio**: `GenerarComprobanteUseCase` retorna la ruta del archivo al `DescargarComprobanteUseCase`.

10. **Dominio**: `DescargarComprobanteUseCase` crea un objeto `File` con la ruta recibida y solicita permisos de almacenamiento a través del `PermissionHandlerService.requestStoragePermission()`.

11. **Dominio**: según la plataforma y los permisos obtenidos, el caso de uso determina la ubicación final:
    - **Android con permisos**: copia el archivo a `/storage/emulated/0/Download` o al directorio de almacenamiento externo.
    - **iOS**: mantiene el archivo en el directorio de documentos de la app (no requiere permisos).
    - **Desktop (Windows/Linux/macOS)**: copia el archivo a la carpeta Descargas del usuario.

12. **Dominio**: después de guardar el archivo, el caso de uso intenta abrirlo automáticamente usando `OpenFile.open()`. Si falla, continúa sin error.

13. **Dominio -> Presentación**: el `DescargarComprobanteUseCase` retorna la ruta final donde se guardó el archivo.

14. **Presentación**: la pantalla recibe la ruta, establece `_isDownloading = false`, y muestra un mensaje de éxito al usuario indicando dónde se guardó el comprobante.

## Flujo de datos: ejemplo de Compartir Comprobante

Para ilustrar el flujo de compartición:

1. **Presentación**: el usuario está visualizando un comprobante y presiona el botón "Compartir".

2. **Presentación -> Dominio**: se invoca al `CompartirComprobanteUseCase.execute` pasando la entidad `ComprobanteEntity`.

3. **Dominio**: el caso de uso llama primero al `GenerarComprobanteUseCase.execute` para generar el PDF (siguiendo el mismo proceso descrito anteriormente).

4. **Dominio**: con la ruta del PDF generado, el caso de uso crea un objeto `XFile` con la ruta del archivo.

5. **Dominio -> Servicios**: el caso de uso invoca al servicio `SharePlus.share()` pasando:
   - El texto descriptivo: "Comprobante de pago #[ID]"
   - El asunto: "Comprobante CSSAyP"
   - El archivo PDF como adjunto

6. **Servicios**: `SharePlus` abre el diálogo nativo del sistema operativo para compartir, mostrando las aplicaciones disponibles (WhatsApp, Email, Drive, etc.).

7. **Servicios -> Dominio**: cuando el usuario selecciona una app o cancela, `SharePlus` retorna el resultado con el estado de la operación.

8. **Dominio**: el caso de uso verifica el resultado. Si el estado es `ShareResultStatus.dismissed`, simplemente retorna sin acción adicional.

9. **Dominio -> Presentación**: el caso de uso completa la ejecución.

10. **Presentación**: la pantalla puede mostrar un mensaje de confirmación si es necesario.

## Características Especiales del Módulo

### Generación Dinámica de PDF

El módulo utiliza un servicio especializado para generar comprobantes en formato PDF:

- Formato diferenciado según tipo de boleta (inicio vs finalización)
- Inclusión de datos del usuario autenticado
- Presentación estructurada de información de pago
- Generación de documentos listos para imprimir o presentar formalmente

### Gestión Multiplataforma de Archivos

Implementa lógica específica para cada plataforma:

- **Android**: manejo de permisos de almacenamiento, guardado en carpeta Downloads pública
- **iOS**: uso de directorio de documentos de la app sin permisos especiales
- **Desktop**: guardado en carpeta Descargas del sistema operativo
- Apertura automática del archivo después de descarga

### Compartición Nativa

Integración con las capacidades nativas de compartir del sistema operativo:

- Uso de la biblioteca `share_plus` para diálogo nativo
- Soporte para múltiples aplicaciones destino
- Inclusión de archivo adjunto y metadatos descriptivos
- Manejo de cancelación de usuario

### Manejo de Errores Robusto

El módulo implementa múltiples capas de manejo de errores:

- Detección de errores de red (timeout, falta de conexión)
- Manejo de respuestas de error de la API
- Validación de usuario autenticado antes de generar PDFs
- Gestión de errores de permisos de almacenamiento
- Manejo silencioso de errores al abrir archivos

### Separación Clara de Responsabilidades

El módulo mantiene una clara separación:

- **Repositorio**: solo obtiene datos remotos y transforma a entidades
- **Casos de uso de obtención**: gestionan la lógica de obtención de datos
- **Casos de uso de generación**: manejan la creación de PDFs con servicios externos
- **Casos de uso de descarga/compartición**: orquestan operaciones del sistema operativo
- **Pantallas**: solo presentan información y delegan acciones

### Soporte para Múltiples Tipos de Comprobantes

Arquitectura flexible que soporta diferentes tipos de comprobantes:

- Comprobantes de inicio con formato específico para boletas únicas de iniciación
- Comprobantes de finalización con múltiples boletas y distribución de montos
- Estructura extensible para agregar nuevos tipos de comprobantes en el futuro

### Tipado Fuerte con Records

Uso de tipos personalizados de Dart para mayor seguridad:

- `BoletaPagada`: estructura clara de datos de boleta
- `MontoOrganismo`: tipado explícito para distribución de montos
- Reducción de errores en tiempo de compilación
- Mejor autocompletado y documentación en el IDE

Esta arquitectura permite que el módulo de comprobantes sea mantenible, testeable y fácilmente extensible para incorporar nuevas funcionalidades como caché local, visualización en línea de PDFs o integración con más métodos de compartición.
