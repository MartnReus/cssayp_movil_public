## Pruebas Unitarias

### Objetivo
El objetivo principal de las pruebas unitarias es garantizar el correcto funcionamiento de los componentes individuales del módulo de notificaciones, incluyendo la obtención de notificaciones desde APIs remotas, la gestión de estados de lectura de notificaciones, el registro de dispositivos para notificaciones push, y la integración con Firebase Cloud Messaging. Estas pruebas permiten detectar errores de forma temprana en el ciclo de desarrollo, asegurando que cada unidad de código cumpla con su responsabilidad de manera aislada, sin depender de otros módulos.

### Herramientas utilizadas
Para la implementación de las pruebas unitarias se utilizaron las siguientes herramientas:

- `flutter_test`: Proporciona un conjunto de utilidades y funciones para crear y ejecutar pruebas unitarias en aplicaciones Flutter, permitiendo validar el comportamiento de widgets, clases y lógica de negocio de manera aislada.
- `mockito`: Permite simular dependencias externas, como APIs de notificaciones, servicios de Firebase Cloud Messaging o servicios de autenticación, lo que facilita probar los componentes de manera controlada sin depender de recursos reales. Esto asegura que las pruebas sean reproducibles y predecibles.
- `flutter_riverpod`: Utilizado para probar la gestión de estado con providers, permitiendo validar el comportamiento de los notifiers y la reactividad del estado.

El uso combinado de estas herramientas permite garantizar la calidad del código, detectar errores de forma temprana y mantener un flujo de desarrollo más seguro y eficiente.

### Alcance

#### Total de Pruebas por Capa
- **Capa de Datos:** 18 pruebas
- **Capa de Dominio:** 6 pruebas
- **Total:** 24 pruebas unitarias

#### Funcionalidades Cubiertas
- Obtención de datos de notificaciones desde API remota
- Validación de respuestas exitosas y errores del servidor
- Manejo de diferentes códigos de estado HTTP (200, 404, 500)
- Gestión de autenticación mediante tokens JWT
- Mapeo de datos de respuesta a entidades de dominio
- Marcado de notificaciones como leídas
- Registro de dispositivos para notificaciones push
- Integración con Firebase Cloud Messaging
- Solicitud de permisos de notificaciones
- Configuración de opciones de presentación de notificaciones en primer plano
- Suscripción y desuscripción a topics de Firebase
- Obtención de tokens FCM
- Validación de autenticación de usuario para operaciones
- Manejo de respuestas paginadas de notificaciones
- Validación de campos opcionales y nulos en respuestas

#### Casos de Error Cubiertos
- Errores de servidor (404, 500)
- Errores de autenticación (token nulo)
- Errores de propagación de excepciones desde data sources
- Manejo de tokens FCM nulos
- Validación de parámetros de entrada
- Manejo de dispositivos desconocidos (entornos de test)

### Detalles por Capa

#### Capa de Datos (18 pruebas)
**DataSources:**
- `notificaciones_data_source_test.dart`: 6 pruebas
  - Obtención exitosa de datos de notificaciones (status 200)
  - Manejo de errores del servidor en obtención de notificaciones (404)
  - Marcado exitoso de notificaciones como leídas (status 200)
  - Manejo de errores del servidor en marcado de notificaciones (500)
  - Registro exitoso de dispositivo (status 200)
  - Manejo de errores del servidor en registro de dispositivo (500)
  - Validación de construcción correcta de URLs
  - Validación de headers de autenticación
  - Validación de formato de body en requests POST

**Repositories:**
- `notificaciones_repository_impl_test.dart`: 7 pruebas
  - Mapeo correcto de respuestas exitosas a entidades
  - Obtención de token JWT desde servicio
  - Validación de token nulo en obtención de notificaciones
  - Propagación de excepciones del data source
  - Validación de token nulo en marcado de notificaciones
  - Validación de token nulo en registro de dispositivo
  - Verificación de parámetros pasados al data source

- `firebase_notification_repository_impl_test.dart`: 5 pruebas
  - Solicitud de permisos de notificaciones con configuración correcta
  - Configuración de opciones de presentación en primer plano
  - Obtención exitosa de token FCM
  - Manejo de token FCM nulo
  - Suscripción exitosa a topics de Firebase
  - Desuscripción exitosa de topics de Firebase

#### Capa de Dominio (6 pruebas)
**Use Cases:**
- `obtener_listado_notificaciones_usecase_test.dart`: 2 pruebas
  - Validación de autenticación de usuario (usuario nulo)
  - Obtención exitosa de listado de notificaciones
  - Validación de parámetros pasados al repositorio
  - Verificación de que no se llama al repositorio si el usuario no está autenticado

- `marcar_notificaciones_leidas_usecase_test.dart`: 2 pruebas
  - Validación de autenticación de usuario (usuario nulo)
  - Marcado exitoso de notificaciones como leídas
  - Validación de parámetros pasados al repositorio
  - Verificación de que no se llama al repositorio si el usuario no está autenticado

- `registrar_dispositivo_usecase_test.dart`: 2 pruebas
  - Validación de autenticación de usuario (usuario nulo)
  - Registro exitoso de dispositivo como "Desconocido" en entornos de test
  - Validación de parámetros pasados al repositorio
  - Verificación de que no se llama al repositorio si el usuario no está autenticado

### Resultados
Las pruebas unitarias del módulo de notificaciones proporcionan una cobertura completa de todas las funcionalidades críticas, incluyendo:

- Validación exhaustiva de la lógica de negocio en cada capa.
- Manejo robusto de errores con casos específicos para cada tipo de excepción.
- Simulación completa de dependencias externas usando Mockito (APIs HTTP, Firebase Messaging, servicios de autenticación).
- Verificación de integración con Firebase Cloud Messaging.
- Validación de autenticación de usuario para operaciones sensibles.
- Validación de mapeo de datos entre capas.
- Pruebas de obtención y gestión de notificaciones paginadas.
- Validación de registro de dispositivos para notificaciones push.
- Manejo de permisos y configuración de notificaciones.
- Validación de campos opcionales y valores nulos.
- Casos de fallback para dispositivos desconocidos en entornos de test.

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de notificaciones cumple con los requisitos de calidad y funcionalidad esperados, garantizando la confiabilidad en la obtención, gestión y entrega de notificaciones push a los usuarios.

