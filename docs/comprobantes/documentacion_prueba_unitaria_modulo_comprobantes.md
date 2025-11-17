## Pruebas Unitarias

### Objetivo
El objetivo principal de las pruebas unitarias es garantizar el correcto funcionamiento de los componentes individuales del módulo de comprobantes, incluyendo la obtención de datos de comprobantes desde APIs remotas, la gestión de estados de comprobantes, y la generación y compartición de comprobantes en formato PDF. Estas pruebas permiten detectar errores de forma temprana en el ciclo de desarrollo, asegurando que cada unidad de código cumpla con su responsabilidad de manera aislada, sin depender de otros módulos.

### Herramientas utilizadas
Para la implementación de las pruebas unitarias se utilizaron las siguientes herramientas:

- `flutter_test`: Proporciona un conjunto de utilidades y funciones para crear y ejecutar pruebas unitarias en aplicaciones Flutter, permitiendo validar el comportamiento de widgets, clases y lógica de negocio de manera aislada.
- `mockito`: Permite simular dependencias externas, como APIs de comprobantes, servicios de generación de PDF o servicios de almacenamiento, lo que facilita probar los componentes de manera controlada sin depender de recursos reales. Esto asegura que las pruebas sean reproducibles y predecibles.
- `flutter_riverpod`: Utilizado para probar la gestión de estado con providers, permitiendo validar el comportamiento de los notifiers y la reactividad del estado.

El uso combinado de estas herramientas permite garantizar la calidad del código, detectar errores de forma temprana y mantener un flujo de desarrollo más seguro y eficiente.

### Alcance

#### Total de Pruebas por Capa
- **Capa de Datos:** 20 pruebas
- **Capa de Dominio:** 14 pruebas
- **Capa de Presentación:** 13 pruebas
- **Total:** 47 pruebas unitarias

#### Funcionalidades Cubiertas
- Obtención de datos de comprobantes desde API remota
- Validación de respuestas exitosas y errores del servidor
- Manejo de diferentes códigos de estado HTTP (200, 400, 404, 500)
- Gestión de excepciones de red (SocketException, TimeoutException)
- Mapeo de datos de respuesta a entidades de dominio
- Generación de comprobantes en formato PDF
- Compartición de comprobantes mediante servicios de share
- Gestión de estados de comprobantes (inicial, carga, éxito, error)
- Validación de autenticación de usuario para operaciones
- Manejo de comprobantes con múltiples boletas pagadas
- Validación de campos opcionales y nulos en respuestas

#### Casos de Error Cubiertos
- Errores de conexión (timeout, socket)
- Errores de servidor (400, 404, 500)
- Errores de parsing JSON (FormatException)
- Errores de validación (usuario no autenticado)
- Errores de generación de PDF
- Excepciones inesperadas durante el procesamiento
- Manejo de respuestas con campos faltantes
- Validación de parámetros de entrada

### Detalles por Capa

#### Capa de Datos (20 pruebas)
**DataSources:**
- `comprobantes_remote_data_source_test.dart`: 10 pruebas
  - Obtención exitosa de datos de comprobantes (status 200)
  - Manejo de errores del servidor (400, 404, 500)
  - Manejo de errores de conexión (SocketException, TimeoutException)
  - Validación de parsing JSON y FormatException
  - Manejo de excepciones inesperadas
  - Validación de construcción correcta de URLs
  - Manejo de campos opcionales como null
  - Validación de mensajes de error por defecto

**Repositories:**
- `comprobantes_repository_impl_test.dart`: 10 pruebas
  - Mapeo correcto de respuestas exitosas a entidades
  - Validación de mapeo de datos con múltiples boletas
  - Manejo de errores del data source remoto
  - Propagación de excepciones
  - Validación de parámetros de entrada
  - Manejo de listas vacías de boletas
  - Validación de campos opcionales (comprobanteLink, metodoPago)
  - Manejo de comprobantes con montos de organismos complejos
  - Verificación de que no se utiliza el data source local

#### Capa de Dominio (14 pruebas)
**Use Cases:**
- `descargar_comprobante_usecase_test.dart`: 14 pruebas
  - Generación exitosa de PDF de comprobante
  - Validación de autenticación de usuario
  - Propagación de excepciones del servicio de PDF
  - Validación de parámetros pasados al servicio de PDF
  - Generación y compartición exitosa de comprobantes
  - Validación de parámetros de compartición (texto, subject, archivo)
  - Manejo de diferentes estados de compartición (success, dismissed, unavailable)
  - Validación de orden de ejecución (usuario -> PDF -> share)
  - Manejo de errores durante la generación de PDF
  - Validación de comprobantes con diferentes IDs
  - Verificación de que no se comparte si falla la generación de PDF

#### Capa de Presentación (13 pruebas)
**Providers:**
- `comprobantes_notifier_test.dart`: 13 pruebas
  - Creación de estados con comprobantes
  - Operaciones copyWith e inmutabilidad de estados
  - Inicialización con estado vacío por defecto
  - Obtención exitosa de comprobantes y actualización de estado
  - Manejo de errores y estados AsyncError
  - Validación de parámetros pasados al use case
  - Manejo de múltiples llamadas independientes
  - Actualización de todos los campos del comprobante
  - Manejo de comprobantes con listas vacías de boletas
  - Manejo de diferentes tipos de errores
  - Validación de estados de carga durante la obtención

### Resultados
Las pruebas unitarias del módulo de comprobantes proporcionan una cobertura completa de todas las funcionalidades críticas, incluyendo:

- Validación exhaustiva de la lógica de negocio en cada capa.
- Manejo robusto de errores con casos específicos para cada tipo de excepción.
- Simulación completa de dependencias externas usando Mockito.
- Verificación de estados y transiciones en los providers.
- Validación de mapeo de datos entre capas.
- Pruebas de generación y compartición de PDFs.
- Validación de autenticación de usuario para operaciones sensibles.
- Casos de fallback y recuperación de errores.
- Validación de campos opcionales y valores nulos.
- Manejo de comprobantes con estructuras complejas (múltiples boletas, montos de organismos).

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de comprobantes cumple con los requisitos de calidad y funcionalidad esperados, garantizando la confiabilidad en la obtención, generación y compartición de comprobantes de pago.

