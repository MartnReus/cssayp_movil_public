# Documentación de la Arquitectura: Módulo de Pagos

Este documento detalla la arquitectura específica del módulo de Pagos. La implementación se adhiere a los principios de Arquitectura Limpia (Clean Architecture) definidos en la [documentación de la arquitectura general](/docs/arquitectura_general.md), organizando el código en las capas de Presentación, Dominio y Datos.

El objetivo de este módulo es gestionar todos los aspectos relacionados con el pago de boletas de inicio y finalización: selección de boletas a pagar, integración con múltiples métodos de pago (PayWay, Red Link), procesamiento de transacciones, verificación de estados de pago y confirmación de resultados.

## Capa de Presentación (Presentation)

Es la responsable de la interfaz de usuario (UI) y la gestión del estado local de la misma. Se comunica con la capa de Dominio a través de **Providers** para ejecutar acciones y reaccionar a los cambios de estado.

### Componentes Principales de la Capa de Presentación

#### Vistas (Screens/Widgets)

Son los componentes visuales con los que el usuario interactúa.

- `pagos_principal_screen.dart`: Pantalla principal del módulo de pagos que muestra las boletas pendientes de pago organizadas en tabs (Inicio/Finalización). Permite seleccionar una o múltiples boletas según el tipo, con restricción de que solo se puede pagar una boleta de inicio a la vez. Incluye resumen de selección con total calculado.

- `procesar_pago_screen.dart`: Pantalla intermedia que coordina el proceso de pago. Muestra el selector de método de pago y gestiona la navegación hacia el formulario correspondiente según el método elegido.

- `red_link_payment_screen.dart`: Pantalla específica para pagos con Red Link. Muestra la URL de pago generada, permite abrir el home banking del usuario, e incluye un sistema de monitoreo automático del estado del pago con actualizaciones periódicas.

- `pago_exitoso_screen.dart`: Pantalla de confirmación que se muestra después de completar exitosamente una transacción. Presenta los detalles del pago realizado y opciones para navegar de regreso.

#### Widgets Especializados

- `metodo_de_pago_selector.dart`: Widget que permite al usuario seleccionar entre los métodos de pago disponibles (PayWay para boletas de fin, Red Link para boletas de inicio). Adapta las opciones mostradas según el tipo de boletas seleccionadas.

- `payway_form.dart`: Formulario completo para pagos con tarjeta. Incluye campos para datos del titular (nombre, DNI), número de tarjeta, CVV, fecha de vencimiento, selector de tipo de tarjeta (débito/crédito) y selector de cuotas para tarjetas de crédito. Implementa validación en tiempo real con algoritmo de Luhn para número de tarjeta.

#### Gestores de Estado (Providers)

Se utiliza `Riverpod` para la gestión de estado y la inyección de dependencias. Los providers orquestan las interacciones del usuario, llaman a los casos de uso de la capa de Dominio y exponen el estado a la UI.

- `pagos_providers.dart`: Centraliza la inyección de dependencias para todo el módulo de pagos, incluyendo la configuración de datasources, repositorios y casos de uso tanto para PayWay como para Red Link.

- `pagos_use_cases_providers.dart`: Provider específico para la inyección de casos de uso del módulo, facilitando la gestión y testing.

- `payway_notifier.dart`: Gestiona el estado completo del flujo de pago con PayWay (`PayWayState`). Incluye lógica de validación de datos de tarjeta con algoritmo de Luhn, manejo de campos tocados para validación progresiva, gestión de errores específicos por campo, y procesamiento del pago con manejo de respuestas de la pasarela.

- `red_link_notifier.dart`: Administra el estado del flujo de pago con Red Link (`RedLinkState`). Maneja la generación de URL de pago, el monitoreo automático del estado del pago mediante polling cada 5 segundos con timeout de 10 minutos, y la gestión de subscripciones de streams para actualizaciones en tiempo real.

- `metodo_pago_selector_provider.dart`: Provider simple que gestiona el método de pago seleccionado por el usuario, facilitando la comunicación entre el selector y las pantallas de pago.

- `payment_states.dart`: Define los estados base para el manejo de pagos: `PaymentInitial`, `PaymentLoading`, `PaymentSuccess` y `PaymentError`. Estos estados son utilizados por todos los notifiers de pagos para mantener consistencia.

## Capa de Dominio (Domain)

Contiene la lógica de negocio pura del módulo de pagos, sin depender de ninguna implementación externa (UI o base de datos).

### Componentes Principales de la Capa de Dominio

#### Entidades (Entities)

Representan los objetos de negocio centrales.

- `boleta_a_pagar_entity.dart`: Modela una boleta en el contexto de pagos, conteniendo los datos esenciales para procesar una transacción: ID de boleta, monto, carátula del juicio y número de afiliado. Esta entidad es más ligera que `BoletaEntity` ya que solo incluye los datos necesarios para el pago.

#### Repositorios (Interfaces Abstractas)

Definen los contratos que la capa de Datos debe implementar. Describen qué se puede hacer, pero no cómo.

- `base_pago_repository.dart`: Define la interfaz base común para todos los repositorios de pago. Incluye el método `actualizarEstadoLocalBoleta` para mantener sincronizado el estado local de las boletas después de un pago exitoso.

- `payway_repository.dart`: Extiende `BasePagoRepository` y define las operaciones específicas para pagos con PayWay: `pagar` que acepta una lista de boletas y datos de tarjeta, retornando un resultado de pago.

- `red_link_repository.dart`: Define las operaciones para pagos con Red Link: `generarUrlPago` para iniciar el proceso de pago y `verificarEstadoPago` para consultar el estado actual de una transacción.

#### Casos de Uso (Use Cases)

Encapsulan una única regla de negocio o una tarea específica. Son invocados por los **Providers** de la capa de Presentación.

- `pagar_con_payway_use_case.dart`: Orquesta la lógica para procesar un pago con PayWay. Valida los datos de entrada y coordina la comunicación con el repositorio de PayWay para ejecutar la transacción.

- `pagar_con_red_link_use_case.dart`: Maneja tres operaciones principales: `iniciarPago` para generar la URL de pago, `monitorearPago` que retorna un Stream para verificaciones periódicas del estado del pago, y `verificarEstado` para consultas puntuales del estado de la transacción.

## Capa de Datos (Data)

Implementa los repositorios definidos en la capa de Dominio. Es la responsable de obtener los datos de las fuentes correspondientes (API externa de pagos) y de transformar esos datos en las Entidades que el Dominio entiende.

### Componentes Principales de la Capa de Datos

#### Repositorios (Implementaciones)

Clases concretas que implementan las interfaces de la capa de Dominio.

- `payway_repository_impl.dart`: Implementación de `PaywayRepository`. Delega las operaciones de pago al `PaywayDataSource` y maneja la actualización del estado local de boletas después de pagos exitosos.

- `red_link_repository_impl.dart`: Implementación de `RedLinkRepository`. Coordina las operaciones con el `RedLinkDataSource` para generar URLs de pago y verificar estados de transacciones.

#### Fuentes de Datos (Data Sources)

Clases que interactúan directamente con una única fuente de datos.

- `payway_data_source.dart`: Responsable de toda la comunicación con la API de PayWay para procesamiento de pagos con tarjeta. Maneja la serialización de datos de tarjeta de forma segura, envío de peticiones HTTP POST con los datos de pago, y parseo de respuestas de la pasarela de pago.

- `red_link_data_source.dart`: Se encarga de la comunicación con la API de Red Link. Genera las referencias de pago y URLs para redirección al home banking, y consulta el estado de pagos pendientes con manejo de timeouts y reintentos.

#### Modelos (Models)

Representan la estructura de los datos tal como se reciben de la API. Incluyen métodos `fromJson` para el parseo de las respuestas JSON.

- `datos_tarjeta_model.dart`: Modelo que encapsula los datos de una tarjeta de crédito o débito: nombre del titular, DNI, número de tarjeta, CVV, fecha de expiración, tipo de tarjeta (enum `TipoTarjeta`: débito/crédito) y número de cuotas. Incluye métodos de serialización para envío seguro a la API.

- `resultado_pago_model.dart`: Modelo genérico que representa el resultado de cualquier operación de pago, incluyendo código de estado HTTP y mensaje de respuesta (que puede ser String o Map según la fuente de datos).

- `red_link_payment_request_model.dart`: Modelo para estructurar las solicitudes de pago a Red Link, incluyendo el ID de boleta y datos adicionales necesarios para generar la referencia de pago.

- `red_link_payment_response_model.dart`: Incluye dos modelos: `RedLinkPaymentResponseModel` con la URL de pago generada, token de identificación y referencia; y `RedLinkPaymentStatusModel` para el estado del pago con bandera de pagado y mensaje descriptivo.

#### Mapeadores (Mappers)

Las transformaciones de modelos a entidades se realizan principalmente dentro de los repositorios, manteniendo la lógica de mapeo cercana a donde se utilizan los datos. Los modelos incluyen métodos `fromJson` y `toJson` para facilitar la serialización.

## Flujo de datos: ejemplo de Pago con PayWay

Para ilustrar cómo interactúan las capas, a continuación se describe el flujo de un pago con tarjeta exitoso:

1. **Presentación**: el usuario completa el formulario de tarjeta en `payway_form.dart` y presiona "Pagar".

2. **Presentación**: el `PayWayNotifier` valida todos los campos del formulario usando el algoritmo de Luhn para el número de tarjeta y validaciones específicas para cada campo.

3. **Presentación -> Dominio**: si la validación es exitosa, el `PayWayNotifier` invoca al `PagarConPaywayUseCase` pasando la lista de boletas seleccionadas y el `DatosTarjetaModel`.

4. **Dominio**: el `PagarConPaywayUseCase` recibe los datos y llama al método `pagar` del `PaywayRepository` (la interfaz).

5. **Dominio -> Datos**: la inyección de dependencias provee la implementación `PaywayRepositoryImpl`, que recibe la llamada.

6. **Datos**: `PaywayRepositoryImpl` delega la operación al `PaywayDataSource` limpiando y preparando los datos de la tarjeta.

7. **Datos**: `PaywayDataSource` ejecuta la petición POST a la API de PayWay con los datos encriptados. Si es exitosa, parsea la respuesta JSON en un `ResultadoPagoModel`.

8. **Datos**: Si el código de respuesta es 201 (éxito), el datasource retorna el resultado al repositorio.

9. **Datos -> Dominio**: `PaywayRepositoryImpl` retorna el `ResultadoPagoModel` al caso de uso.

10. **Dominio -> Presentación**: El `PagarConPaywayUseCase` retorna el resultado al `PayWayNotifier`.

11. **Presentación**: El `PayWayNotifier` actualiza su estado a `PaymentSuccess` con el resultado del pago. La UI reacciona a este cambio y navega a la pantalla `pago_exitoso_screen.dart` mostrando los detalles de la transacción.

12. **Presentación**: Opcionalmente, se actualiza el cache de boletas en el `BoletasListProvider` para reflejar el nuevo estado de las boletas pagadas.

## Flujo de datos: ejemplo de Pago con Red Link

Para ilustrar el flujo asíncrono de Red Link con monitoreo de estado:

1. **Presentación**: el usuario selecciona una boleta de inicio y elige Red Link como método de pago en `procesar_pago_screen.dart`.

2. **Presentación**: se navega a `red_link_payment_screen.dart` donde el `RedLinkNotifier` inicia el proceso.

3. **Presentación -> Dominio**: el `RedLinkNotifier` invoca al `PagarConRedLinkUseCase.iniciarPago` con el ID de la boleta.

4. **Dominio -> Datos**: el caso de uso llama al método `generarUrlPago` del `RedLinkRepository`.

5. **Datos**: `RedLinkRepositoryImpl` usa el `RedLinkDataSource` para hacer la petición POST a la API de Red Link.

6. **Datos**: `RedLinkDataSource` recibe una respuesta con la URL de pago, token de identificación y referencia, parseándola en un `RedLinkPaymentResponseModel`.

7. **Datos -> Dominio -> Presentación**: El modelo se propaga de vuelta hasta el `RedLinkNotifier`, que actualiza el estado con la URL de pago.

8. **Presentación**: La UI muestra la URL y un botón para abrir el home banking. El usuario hace clic y se abre el navegador externo.

9. **Presentación**: Automáticamente, el `RedLinkNotifier` inicia el monitoreo invocando `iniciarMonitoreo()`.

10. **Presentación -> Dominio**: Se llama a `PagarConRedLinkUseCase.monitorearPago` que retorna un Stream.

11. **Dominio -> Datos**: Cada 5 segundos, el Stream ejecuta una consulta a través de `RedLinkRepository.verificarEstadoPago`.

12. **Datos**: `RedLinkDataSource` hace peticiones GET periódicas a la API de Red Link consultando el estado de la transacción.

13. **Datos -> Dominio -> Presentación**: Cada respuesta se propaga como un `RedLinkPaymentStatusModel` en el Stream.

14. **Presentación**: El `RedLinkNotifier` escucha el Stream. Si recibe `pagado: true`, actualiza el estado a `PaymentSuccess` y cancela la subscripción.

15. **Presentación**: La UI detecta el éxito y navega automáticamente a `pago_exitoso_screen.dart`.

## Características Especiales del Módulo

### Múltiples Métodos de Pago

El módulo está diseñado con una arquitectura flexible que permite integrar múltiples métodos de pago:

- **PayWay**: Para pagos con tarjeta de crédito/débito de boletas de finalización
- **Red Link**: Para pagos vía home banking de boletas de inicio
- **Extensibilidad**: La interfaz `BasePagoRepository` permite agregar nuevos métodos sin modificar el código existente

### Validación Robusta de Datos de Tarjeta

Implementa múltiples capas de validación:

- Algoritmo de Luhn para verificar números de tarjeta válidos
- Validación de formato para CVV, fecha de expiración y DNI
- Validación de fecha de expiración contra fecha actual
- Validación progresiva mostrando errores solo en campos tocados por el usuario

### Monitoreo Asíncrono de Pagos

Para Red Link, donde la confirmación no es inmediata:

- Sistema de polling con intervalo configurable (default 5 segundos)
- Timeout máximo configurable (default 10 minutos)
- Manejo de subscripciones con limpieza automática
- Cancelación manual del monitoreo disponible para el usuario

### Gestión de Estado Complejo

Utiliza un patrón de estado inmutable con estados específicos:

- `PayWayState`: incluye estado de pago, datos de tarjeta, errores de validación, campos tocados, validez del formulario, tipo de tarjeta y número de cuotas
- `RedLinkState`: incluye estado de pago, URL de pago, token de identificación, referencia y ID de boleta
- Estados base de pago: Initial, Loading (con mensaje personalizado), Success (con resultado) y Error (con mensaje de error)

### Seguridad y Cumplimiento

El módulo considera aspectos de seguridad críticos:

- Limpieza de espacios en números de tarjeta antes de enviar
- Los datos de tarjeta nunca se almacenan localmente
- Comunicación exclusiva por HTTPS/TLS con las pasarelas de pago
- Preparado para tokenización en lugar de envío de datos de tarjeta cruda

### Separación de Responsabilidades

Cada método de pago tiene su propio conjunto de:

- Datasource para comunicación con API específica
- Repository implementation con lógica particular
- Notifier con estado y validaciones específicas
- Use case para orquestación de operaciones

Esta separación facilita el mantenimiento, testing y la adición de nuevos métodos de pago sin afectar los existentes.
