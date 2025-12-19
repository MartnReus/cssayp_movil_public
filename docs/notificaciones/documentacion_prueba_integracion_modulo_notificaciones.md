# Pruebas de Integración

## Objetivo

El objetivo principal de las pruebas de integración es validar el funcionamiento completo del módulo de notificaciones en un entorno que simula el comportamiento real del usuario. Estas pruebas verifican la interacción entre diferentes módulos, la navegación entre pantallas, la integración con servicios de Firebase Cloud Messaging, la obtención y visualización de notificaciones, el marcado automático de notificaciones como leídas, y el flujo completo de las funcionalidades de gestión de notificaciones.

## Herramientas utilizadas

Para la implementación de las pruebas de integración se utilizaron las siguientes herramientas:

- `integration_test`: Framework oficial de Flutter para pruebas de integración que permite probar la aplicación completa en un dispositivo real o emulador, simulando interacciones del usuario real.
- `flutter_test`: Proporciona utilidades para testing de widgets y validación de comportamientos en la interfaz de usuario.
- `mockito`: Permite simular servicios externos y dependencias para crear escenarios controlados de prueba.
- `flutter_riverpod`: Facilita la inyección de dependencias y el manejo de estado durante las pruebas.

El uso combinado de estas herramientas permite simular flujos completos de usuario, validar la integración entre componentes y asegurar que el módulo de notificaciones funciona correctamente en condiciones reales.

## Alcance

### Total de Pruebas por Funcionalidad

- **Flujo de Visualización y Marcado de Notificaciones:** 1 prueba
- **Flujo de Estado Vacío:** 1 prueba
- **Total:** 2 pruebas de integración activas

### Funcionalidades Cubiertas

- Navegación inicial y autenticación
- Acceso a la pantalla de notificaciones desde el icono de notificaciones en la barra de navegación
- Visualización de listado de notificaciones con diferentes tipos (Pago Imputado, Boleta por Vencer)
- Visualización de notificaciones leídas y no leídas
- Marcado automático de notificaciones como leídas al acceder a la pantalla
- Manejo de estado vacío cuando no hay notificaciones disponibles
- Integración con Firebase Cloud Messaging mediante Fake Repository
- Integración con servicios de conectividad
- Verificación de invocación correcta de métodos del repositorio mediante spies
- Manejo de respuestas paginadas de notificaciones

### Casos de Error Cubiertos

- Validación de autenticación de usuario
- Manejo de listas vacías de notificaciones
- Verificación de invocación correcta del método de marcado de notificaciones como leídas
- Validación de flujos desde diferentes estados de datos

## Detalles por Funcionalidad

### Flujo de Visualización y Marcado de Notificaciones (1 prueba)

**Archivo:** `notificaciones_flow_test.dart`

- **Flujo completo exitoso:** Valida todo el proceso desde la autenticación, navegación a la pantalla de inicio (Home), acceso a la pantalla de notificaciones mediante el icono de notificaciones en la barra de navegación, visualización del listado de notificaciones con diferentes tipos (Pago Imputado, Boleta por Vencer), verificación de que las notificaciones se muestran correctamente con sus títulos y mensajes, y validación de que el método `marcarNotificacionesComoLeidas` del repositorio fue invocado automáticamente al acceder a la pantalla. Incluye la verificación de que el método fue llamado con los parámetros correctos (lista de UUIDs de notificaciones y número de afiliado).

### Flujo de Estado Vacío (1 prueba)

**Archivo:** `notificaciones_flow_test.dart`

- **Manejo de estado vacío:** Valida el proceso completo desde la autenticación, navegación a la pantalla de inicio, acceso a la pantalla de notificaciones mediante el icono de notificaciones, y visualización del mensaje "No tienes notificaciones" cuando la lista de notificaciones está vacía. Verifica que la aplicación maneja correctamente el caso cuando no hay notificaciones disponibles para mostrar al usuario.

## Características Técnicas

### Simulación de Servicios

- **Mock de Repositorio de Notificaciones:** Simula el comportamiento del repositorio de notificaciones con respuestas controladas de listado de notificaciones y marcado como leídas
- **Mock de Repositorio de Usuario:** Simula el comportamiento del repositorio de usuario con autenticación y obtención de usuario actual
- **Fake Firebase Notification Repository:** Simula la integración con Firebase Cloud Messaging sin invocar servicios reales, devolviendo tokens fake y streams vacíos para evitar problemas con mockito en entornos de prueba
- **Mock de Connectivity Notifier:** Simula el estado de conectividad como siempre online para las pruebas
- **Spy de Repositorio de Notificaciones:** Rastrea las llamadas al método `marcarNotificacionesComoLeidas` manteniendo el comportamiento real de integración

### Datos de Prueba

- **Usuario de prueba:** Usuario con número de afiliado 999 y datos de prueba estándar
- **Notificaciones de prueba:** Incluyen diferentes tipos de notificaciones (Pago Imputado, Boleta por Vencer) con diferentes estados de lectura (leídas y no leídas) y fechas de envío variadas
- **Respuestas paginadas:** Simuladas con datos de notificaciones, links de paginación y metadatos
- **Estados de autenticación:** Usuario autenticado con validación de estado de autenticación y obtención de usuario actual

### Validaciones de UI

- **Presencia de widgets:** Verificación de que los elementos correctos estén visibles (pantallas, iconos, textos de notificaciones)
- **Navegación entre pantallas:** Confirmación de transiciones correctas entre Home y Notificaciones
- **Visualización de notificaciones:** Validación de que se muestren correctamente los títulos y mensajes de las notificaciones
- **Estado vacío:** Verificación de que se muestre el mensaje apropiado cuando no hay notificaciones
- **Interacciones de usuario:** Simulación de toques en iconos de navegación
- **Iconos de navegación:** Validación de la funcionalidad del icono de notificaciones en la barra de navegación

### Flujos de Notificaciones Específicos

#### Visualización y Marcado Automático
- Autenticación de usuario
- Navegación a la pantalla de inicio (Home)
- Acceso a la pantalla de notificaciones mediante icono de notificaciones
- Carga y visualización del listado de notificaciones
- Verificación de que las notificaciones se muestran con sus títulos y mensajes correctos
- Validación de que el método `marcarNotificacionesComoLeidas` fue invocado automáticamente
- Verificación de que el método fue llamado con los parámetros correctos (UUIDs de notificaciones y número de afiliado)

#### Estado Vacío
- Autenticación de usuario
- Navegación a la pantalla de inicio
- Acceso a la pantalla de notificaciones mediante icono de notificaciones
- Verificación de que se muestra el mensaje "No tienes notificaciones" cuando la lista está vacía
- Validación del manejo correcto del estado vacío en la UI

## Resultados

Las pruebas de integración del módulo de notificaciones proporcionan una validación completa del funcionamiento end-to-end, incluyendo:

- Verificación exhaustiva de flujos completos de visualización y gestión de notificaciones desde la navegación inicial hasta la visualización del listado.
- Validación de la integración entre el módulo de notificaciones y todos los demás módulos de la aplicación (autenticación, navegación principal).
- Simulación realista de interacciones de usuario y obtención de notificaciones desde el repositorio.
- Navegación correcta entre pantallas y verificación de estados de carga y visualización.
- Validación del marcado automático de notificaciones como leídas con verificación de que el repositorio es invocado correctamente.
- Verificación del comportamiento con diferentes tipos de notificaciones (Pago Imputado, Boleta por Vencer).
- Pruebas de flujos alternativos incluyendo el manejo de estado vacío cuando no hay notificaciones disponibles.
- Validación de la integración con Firebase Cloud Messaging mediante Fake Repository para evitar dependencias de servicios externos en pruebas.
- Verificación de la gestión de conectividad durante las operaciones de notificaciones.

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de notificaciones funciona correctamente en un entorno de integración completo y cumple con los requisitos de funcionalidad y experiencia de usuario esperados para la visualización, gestión y marcado automático de notificaciones.

