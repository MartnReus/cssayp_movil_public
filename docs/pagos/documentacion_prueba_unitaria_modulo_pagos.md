## Pruebas Unitarias

### Objetivo
El objetivo principal de las pruebas unitarias es garantizar el correcto funcionamiento de los componentes individuales del módulo de pagos, incluyendo la integración con sistemas de pago externos como Payway y Red Link, la validación de datos de tarjetas, y la gestión de estados de pago. Estas pruebas permiten detectar errores de forma temprana en el ciclo de desarrollo, asegurando que cada unidad de código cumpla con su responsabilidad de manera aislada, sin depender de otros módulos.

### Herramientas utilizadas
Para la implementación de las pruebas unitarias se utilizaron las siguientes herramientas:

- `flutter_test`: Proporciona un conjunto de utilidades y funciones para crear y ejecutar pruebas unitarias en aplicaciones Flutter, permitiendo validar el comportamiento de widgets, clases y lógica de negocio de manera aislada.
- `mockito`: Permite simular dependencias externas, como APIs de pago, servicios de validación de tarjetas o servicios de almacenamiento, lo que facilita probar los componentes de manera controlada sin depender de recursos reales. Esto asegura que las pruebas sean reproducibles y predecibles.
- `flutter_riverpod`: Utilizado para probar la gestión de estado con providers, permitiendo validar el comportamiento de los notifiers y la reactividad del estado.

El uso combinado de estas herramientas permite garantizar la calidad del código, detectar errores de forma temprana y mantener un flujo de desarrollo más seguro y eficiente.

### Alcance

#### Total de Pruebas por Capa
- **Capa de Datos:** 42 pruebas
- **Capa de Dominio:** 27 pruebas
- **Capa de Presentación:** 149 pruebas
- **Widgets:** 38 pruebas
- **Total:** 256 pruebas unitarias

#### Funcionalidades Cubiertas
- Procesamiento de pagos con Payway (tarjetas de crédito/débito)
- Generación y monitoreo de pagos con Red Link
- Validación de datos de tarjetas (algoritmo de Luhn, formato de fechas)
- Gestión de estados de pago (inicial, carga, éxito, error)
- Selección de métodos de pago
- Manejo de formularios de pago
- Gestión de cuotas para tarjetas de crédito
- Monitoreo en tiempo real del estado de pagos
- Manejo de errores de conexión y validación
- Integración con APIs externas de pago

#### Casos de Error Cubiertos
- Errores de conexión (timeout, socket)
- Errores de servidor (400, 500, HTML inesperado)
- Errores de validación (campos requeridos, datos inválidos)
- Errores de procesamiento de pago (tarjeta rechazada, fondos insuficientes)
- Errores de parsing JSON (FormatException)
- Errores de red y conectividad
- Casos de fallback y recuperación de errores
- Validación de tarjetas (algoritmo de Luhn, CVV, fechas)

### Detalles por Capa

#### Capa de Datos (42 pruebas)
**DataSources:**
- `payway_data_source_test.dart`: 8 pruebas
  - Procesamiento de pagos exitosos y errores
  - Manejo de timeouts y excepciones de red
  - Validación de respuestas JSON
  - Casos edge y validaciones especiales
  - Verificación de datos enviados en requests

- `red_link_data_source_test.dart`: 20 pruebas
  - Generación de URLs de pago (casos exitosos y errores)
  - Verificación de estado de pagos
  - Manejo de diferentes códigos de respuesta (200, 201, 400, 500)
  - Gestión de timeouts y excepciones
  - Validación de parámetros de respuesta
  - Casos especiales (valores enteros vs booleanos)

**Repositories:**
- `payway_repository_impl_test.dart`: 14 pruebas
  - Integración entre data sources y lógica de negocio
  - Manejo de diferentes tipos de tarjetas (crédito/débito)
  - Validación de listas de boletas
  - Gestión de errores y recuperación
  - Casos de integración con múltiples llamadas
  - Validación de parámetros de entrada

#### Capa de Dominio (27 pruebas)
**Use Cases:**
- `pagar_con_payway_use_case_test.dart`: 11 pruebas
  - Procesamiento de pagos con tarjetas
  - Manejo de diferentes tipos de tarjetas
  - Validación de parámetros de entrada
  - Gestión de errores del repositorio
  - Casos de integración y múltiples llamadas

- `pagar_con_red_link_use_case_test.dart`: 16 pruebas
  - Iniciación de pagos con Red Link
  - Monitoreo de estado de pagos en tiempo real
  - Verificación de estado de pagos
  - Manejo de streams de monitoreo
  - Gestión de intervalos y límites de intentos
  - Casos de error durante el monitoreo

#### Capa de Presentación (149 pruebas)
**Providers:**
- `pagos_providers_test.dart`: 30 pruebas
  - Gestión de selección de boletas
  - Estados de procesamiento de pagos
  - Operaciones de copyWith y inmutabilidad
  - Integración con ProviderContainer
  - Casos edge y manejo de múltiples cambios

- `payway_notifier_test.dart`: 35 pruebas
  - Gestión de datos de formulario de tarjeta
  - Validación de campos (nombre, DNI, número de tarjeta, CVV, fecha)
  - Manejo de tipos de tarjeta y cuotas
  - Procesamiento de pagos
  - Estados de carga y error
  - Casos edge con espacios en blanco y valores extremos

- `red_link_notifier_test.dart`: 29 pruebas
  - Iniciación de pagos con Red Link
  - Monitoreo de estado de pagos
  - Gestión de streams y suscripciones
  - Estados de carga, éxito y error
  - Manejo de URLs de pago y tokens
  - Casos edge con múltiples llamadas

- `metodo_pago_selector_provider_test.dart`: 21 pruebas
  - Selección de métodos de pago
  - Estados de selección y validación
  - Operaciones de copyWith
  - Integración con ProviderContainer

- `payment_states_test.dart`: 34 pruebas
  - Validación de estados inmutables
  - Operaciones copyWith para PayWayState
  - Jerarquía de clases de estado
  - Casos edge con valores extremos

#### Widgets (38 pruebas)
- `metodo_de_pago_selector_test.dart`: 16 pruebas
  - Renderizado de selector de métodos
  - Interacciones de usuario
  - Estilos y iconos
  - Casos edge con selección rápida
  - Información de métodos de pago

- `payway_form_test.dart`: 22 pruebas
  - Renderizado de formulario de pago
  - Validación de campos de entrada
  - Formateo de datos (número de tarjeta, fecha)
  - Selector de tipo de tarjeta y cuotas
  - Integración con notifiers

### Resultados
Las pruebas unitarias del módulo de pagos proporcionan una cobertura completa de todas las funcionalidades críticas, incluyendo:

- Validación exhaustiva de la lógica de negocio en cada capa.
- Manejo robusto de errores con casos específicos para cada tipo de excepción.
- Simulación completa de dependencias externas usando Mockito.
- Verificación de estados y transiciones en los providers.
- Validación de formularios con casos de éxito y error.
- Pruebas de widgets con diferentes estados y configuraciones.
- Validación de integración con APIs de pago externas.
- Casos de fallback y recuperación de errores.
- Monitoreo en tiempo real de estados de pago.
- Validación de algoritmos de verificación de tarjetas.

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de pagos cumple con los requisitos de calidad y funcionalidad esperados, garantizando la seguridad y confiabilidad en el procesamiento de transacciones financieras.
