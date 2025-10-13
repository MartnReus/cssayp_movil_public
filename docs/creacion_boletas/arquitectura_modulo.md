# Documentación de la Arquitectura: Módulo de Boletas

Este documento detalla la arquitectura específica del módulo de Boletas. La implementación se adhiere a los principios de Arquitectura Limpia (Clean Architecture) definidos en la [documentación de la arquitectura general](/docs/arquitectura_general.md), organizando el código en las capas de Presentación, Dominio y Datos.

El objetivo de este módulo es gestionar todos los aspectos relacionados con la creación, consulta y gestión de boletas: generación de boletas de inicio y finalización, historial de boletas, búsqueda de boletas pagadas, y visualización de información de juicios asociados.

## Capa de Presentación (Presentation)

Es la responsable de la interfaz de usuario (UI) y la gestión del estado local de la misma. Se comunica con la capa de Dominio a través de **Providers** para ejecutar acciones y reaccionar a los cambios de estado.

### Componentes Principales

#### Vistas (Screens/Widgets)

Son los componentes visuales con los que el usuario interactúa.

- `crear_boleta_screen.dart`: Pantalla principal que permite al usuario elegir entre crear una boleta de inicio o finalización. Se accede utilizando el botón "Nueva boleta" de la pantalla Home.

- `boleta_inicio_paso1.dart`, `boleta_inicio_paso2.dart`, `boleta_inicio_paso3.dart`: Flujo de creación de boleta de inicio dividido en pasos para una mejor experiencia de usuario. Incluye validación de datos, confirmación y resultado final.

- `boleta_fin_paso1.dart`, `boleta_fin_paso2.dart`, `boleta_fin_paso3.dart`: Flujo de creación de boleta de finalización que incluye la búsqueda de boletas de inicio pagadas, ingreso de datos adicionales como honorarios y regulación, y confirmación final.

- `boleta_generada.dart`: Pantalla de confirmación que se muestra después de crear exitosamente una boleta, mostrando los detalles relevantes.

- `historial_screen.dart`: Pantalla principal que contiene dos tabs: historial de boletas e historial de juicios, utilizando un `TabController` para la navegación.

#### Widgets Especializados

- `historial_boletas.dart`: Widget que maneja la visualización del historial de boletas con paginación, filtros y soporte para modo offline.

- `historial_juicios.dart`: Widget que gestiona la visualización del historial de juicios con funcionalidades de búsqueda y paginación.

#### Gestores de Estado (Providers)

Se utiliza `Riverpod` para la gestión de estado y la inyección de dependencias. Los providers orquestan las interacciones del usuario, llaman a los casos de uso de la capa de Dominio y exponen el estado a la UI.

- `boletas_list_provider.dart`: Gestiona el estado principal de las boletas (`BoletasState`), incluyendo la lista de boletas, paginación, estado de carga, manejo de errores y soporte offline con sincronización automática.

- `boleta_inicio_data_provider.dart`: Maneja el estado y la lógica específica para la creación de boletas de inicio, incluyendo la validación de datos.

- `boleta_fin_data_provider.dart`: Administra el estado y la lógica para la creación de boletas de finalización, incluyendo la búsqueda de boletas de inicio pagadas y validación de datos.

- `juicios_provider.dart`: Gestiona el estado de los juicios, incluyendo la búsqueda, filtrado y paginación de información relacionada con los procesos judiciales.

- `boletas_use_cases_providers.dart`: Centraliza la inyección de dependencias para todos los casos de uso del módulo, facilitando la gestión y testing.

## Capa de Dominio (Domain)

Contiene la lógica de negocio pura del módulo de boletas, sin depender de ninguna implementación externa (UI o base de datos).

### Componentes Principales

#### Entidades (Entities)

Representan los objetos de negocio centrales.

- `boleta_entity.dart`: Modela una boleta con todos sus atributos: ID, tipo (inicio/finalización), monto, fechas de impresión y vencimiento, información del juicio (carátula), estado de pago, y campos adicionales como número de expediente y gastos administrativos. Incluye métodos de negocio como `estaPagada` y `estaVencida`.

- `juicio_entity.dart`: Representa un juicio con su información básica: carátula, número de expediente, año y CUIJ (Código Único de Identificación Judicial).

- `parametros_boleta_inicio_entity.dart`: Contiene los parámetros necesarios para la creación de boletas de inicio, como montos mínimos y máximos permitidos.

- `estado_boleta.dart`: Enum que define los posibles estados de una boleta: `pagada`, `pendiente`, `vencida`, `noCreada`.

- `boleta_tipo.dart`: Enum que define los tipos de boletas disponibles: `inicio`, `finalizacion`, `desconocido`.

#### Repositorios (Interfaces Abstractas)

Definen los contratos que la capa de Datos debe implementar. Describen qué se puede hacer, pero no cómo.

- `boletas_repository.dart`: Define las operaciones principales relacionadas con boletas: `crearBoletaInicio`, `crearBoletaFinalizacion`, `obtenerBoletasPorJuicio`, `obtenerHistorialBoletas`, y `buscarBoletasInicioPagadas`.

- `juicios_repository.dart`: Define las operaciones relacionadas con la consulta de juicios y su información asociada.

#### Casos de Uso (Use Cases)

Encapsulan una única regla de negocio o una tarea específica. Son invocados por los **Providers** de la capa de Presentación.

- `generar_boleta_inicio_use_case.dart`: Orquesta la lógica para crear una boleta de inicio, incluyendo la obtención del usuario actual y validación de permisos.

- `generar_boleta_finalizacion_use_case.dart`: Maneja la lógica para crear una boleta de finalización, validando la existencia de la boleta de inicio asociada y los datos del proceso judicial.

- `obtener_historial_boletas_use_case.dart`: Se encarga de obtener el historial paginado de boletas del usuario, incluyendo el manejo de filtros y ordenamiento.

- `buscar_boletas_inicio_pagadas_use_case.dart`: Gestiona la búsqueda de boletas de inicio que han sido pagadas y están disponibles para crear boletas de finalización.

- `listar_juicios_use_case.dart`: Maneja la lógica para obtener la lista de juicios con paginación y filtros de búsqueda.

- `obtener_parametros_boleta_inicio_use_case.dart`: Se encarga de obtener los parámetros necesarios para la validación durante la creación de boletas de inicio.

## Capa de Datos (Data)

Implementa los repositorios definidos en la capa de Dominio. Es la responsable de obtener los datos de las fuentes correspondientes (API, almacenamiento local) y de transformar esos datos en las Entidades que el Dominio entiende.

### Componentes Principales

#### Repositorios (Implementaciones)

Clases concretas que implementan las interfaces de la capa de Dominio.

- `boletas_repository_impl.dart`: Implementación de `BoletasRepository`. Coordina `BoletasDataSource` y `BoletasLocalDataSource` para realizar operaciones CRUD de boletas, manejar caché local y sincronización con la API.

- `juicios_repository_impl.dart`: Implementación de `JuiciosRepository`. Gestiona la obtención de información de juicios desde las fuentes de datos correspondientes.

#### Fuentes de Datos (Data Sources)

Clases que interactúan directamente con una única fuente de datos.

- `boletas_data_source.dart`: Responsable de toda la comunicación con la API REST para las operaciones de boletas. Maneja peticiones HTTP, serialización JSON y manejo de errores de red.

- `boletas_local_data_source.dart`: Se encarga del almacenamiento local de boletas utilizando SQLite a través de `sqflite`. Proporciona funcionalidades de caché para soporte offline, incluyendo operaciones de guardado, consulta con filtros y paginación local.

#### Modelos (Models)

Representan la estructura de los datos tal como se reciben de la API. Incluyen métodos `fromJson` para el parseo de las respuestas JSON.

- `crear_boleta_response_models.dart`: Modelos para las respuestas de creación de boletas, incluyendo tanto respuestas exitosas como de error, con sus respectivos campos específicos.

- `historial_boletas_response_models.dart`: Modelos para las respuestas del historial de boletas, incluyendo metadatos de paginación y estructura de datos de boletas.

- `boleta_inicio_pagada_model.dart`: Modelo específico para boletas de inicio que han sido pagadas y están disponibles para crear boletas de finalización.

- `paginated_response_model.dart`: Modelo genérico para respuestas paginadas que incluye metadatos como página actual, total de páginas, cantidad de elementos, etc.

#### Mapeadores (Mappers)

Funciones responsables de convertir los **Models** de la capa de Datos en **Entities** de la capa de Dominio.

- Los mapeadores están integrados dentro de `BoletaEntity.fromJson()` y los repositorios correspondientes, transformando las respuestas de la API en entidades de dominio mientras mantienen la separación de responsabilidades.

## Flujo de datos: ejemplo de Creación de Boleta de Inicio

Para ilustrar cómo interactúan las capas, a continuación se describe el flujo de creación de una boleta de inicio:

1. **Presentación**: el usuario completa el formulario en `boleta_inicio_paso2.dart` y presiona "Crear Boleta".

2. **Presentación**: el `BoletaInicioDataProvider` es notificado y llama al método `crearBoletaInicio` con la carátula y monto.

3. **Presentación -> Dominio**: el provider invoca al `GenerarBoletaInicioUseCase`.

4. **Dominio**: el `GenerarBoletaInicioUseCase` primero obtiene el usuario actual a través del `UsuarioRepository` para validar permisos y obtener el número de afiliado.

5. **Dominio -> Datos**: el caso de uso llama al método `crearBoletaInicio` del `BoletasRepository` (implementación `BoletasRepositoryImpl`).

6. **Datos**: `BoletasRepositoryImpl` obtiene el dígito de autenticación del `JwtTokenService` y llama a `BoletasDataSource`.

7. **Datos**: `BoletasDataSource` ejecuta la petición POST a la API. Si es exitosa, parsea la respuesta JSON en un `CrearBoletaSuccessResponse`.

8. **Datos**: `BoletasRepositoryImpl` recibe la respuesta, calcula el monto final y fechas, y crea una `BoletaEntity` usando los datos mapeados.

9. **Datos**: Opcionalmente, la boleta creada se guarda en el almacenamiento local a través de `BoletasLocalDataSource` para soporte offline.

10. **Datos -> Dominio**: `BoletasRepositoryImpl` retorna la `BoletaEntity` al `GenerarBoletaInicioUseCase`.

11. **Dominio -> Presentación**: El caso de uso retorna la `BoletaEntity` al `BoletaInicioDataProvider`.

12. **Presentación**: El provider actualiza su estado y navega a la pantalla `boleta_generada.dart` mostrando los detalles de la boleta creada. Simultáneamente, actualiza el cache del `BoletasListProvider` para reflejar la nueva boleta en el historial.

## Características Especiales del Módulo

### Soporte Offline

El módulo implementa un robusto sistema de caché local que permite:

- Consultar el historial de boletas sin conexión a internet
- Sincronización automática cuando se recupera la conectividad
- Indicadores visuales del estado de conectividad y última sincronización

### Gestión de Estado Complejo

Utiliza un patrón de estado inmutable con `BoletasState` que incluye:

- Lista de boletas con paginación
- Estado de carga y errores
- Metadatos de paginación (página actual, total, siguiente/anterior)
- Información de sincronización offline

### Validación de Negocio

Implementa validaciones específicas del dominio como:

- Montos mínimos y máximos para boletas
- Validación de fechas de vencimiento
- Verificación de estados de boletas (pagada, vencida, pendiente)
- Validación de relaciones entre boletas de inicio y finalización
