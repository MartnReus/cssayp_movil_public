# Pruebas de Integración

## Objetivo

El objetivo principal de las pruebas de integración es validar el funcionamiento completo del módulo de comprobantes en un entorno que simula el comportamiento real del usuario. Estas pruebas verifican la interacción entre diferentes módulos, la navegación entre pantallas, la integración con servicios de generación de PDF y descarga de archivos, y el flujo completo de las funcionalidades de visualización y descarga de comprobantes de pago.

## Herramientas utilizadas

Para la implementación de las pruebas de integración se utilizaron las siguientes herramientas:

- `integration_test`: Framework oficial de Flutter para pruebas de integración que permite probar la aplicación completa en un dispositivo real o emulador, simulando interacciones del usuario real.
- `flutter_test`: Proporciona utilidades para testing de widgets y validación de comportamientos en la interfaz de usuario.
- `mockito`: Permite simular servicios externos y dependencias para crear escenarios controlados de prueba.
- `flutter_riverpod`: Facilita la inyección de dependencias y el manejo de estado durante las pruebas.

El uso combinado de estas herramientas permite simular flujos completos de usuario, validar la integración entre componentes y asegurar que el módulo de comprobantes funciona correctamente en condiciones reales.

## Alcance

### Total de Pruebas por Funcionalidad

- **Flujo de Descarga desde Boletas:** 1 prueba
- **Flujo de Descarga desde Juicios:** 1 prueba
- **Total:** 2 pruebas de integración

### Funcionalidades Cubiertas

- Navegación inicial y autenticación
- Visualización de historial de boletas pagadas
- Acceso a comprobantes desde diferentes módulos (Boletas y Juicios)
- Visualización de detalles de comprobantes
- Generación de comprobantes en formato PDF
- Descarga de comprobantes al dispositivo mediante DescargarComprobanteUseCase
- Navegación entre pantallas de comprobantes
- Descarga de boletas de inicio y fin desde el módulo de Juicios
- Verificación de mensajes de éxito mediante SnackBars
- Manejo de diferentes tipos de comprobantes (inicio, fin)
- Verificación de invocación correcta de use cases mediante spies

### Casos de Error Cubiertos

- Validación de autenticación de usuario
- Manejo de estados de carga durante la generación de PDF
- Verificación de invocación correcta del use case de descarga
- Validación de flujos desde diferentes puntos de entrada

## Detalles por Funcionalidad

### Flujo de Descarga desde Boletas (1 prueba)

**Archivo:** `descargar_comprobante_flow_test.dart`

- **Flujo completo exitoso:** Valida todo el proceso desde la autenticación, navegación a la pantalla de Boletas, visualización del historial de boletas pagadas, acceso al detalle del comprobante mediante botón "Ver comprobante", visualización de la pantalla de comprobante de inicio, y descarga exitosa del PDF mediante botón "DESCARGAR" con verificación del SnackBar de éxito "Comprobante generado exitosamente". Incluye la verificación de que el use case de descarga fue llamado correctamente.

### Flujo de Descarga desde Juicios (1 prueba)

**Archivo:** `descargar_comprobante_flow_test.dart`

- **Descarga de boletas de inicio y fin:** Valida el proceso completo desde la autenticación, navegación a la pantalla de Boletas, cambio a la pestaña de Juicios, expansión de juicios mediante ExpansionTile, acceso al detalle del comprobante mediante botón "Ver comprobante" (para inicio y fin si están disponibles), visualización de las pantallas de comprobante correspondientes, y descarga exitosa de boletas de inicio y fin mediante botón "DESCARGAR" con verificación de los SnackBars correspondientes. Incluye la verificación de que el use case de descarga fue llamado al menos una vez.

## Características Técnicas

### Simulación de Servicios

- **Mock de HTTP Client:** Simula respuestas de API para login e historial de boletas con diferentes escenarios
- **Mock de Almacenamiento Seguro:** Simula el almacenamiento seguro de tokens de autenticación
- **Mock de Repositorios:** Simula el comportamiento de repositorios de comprobantes y usuarios
- **Fake GenerarComprobanteUseCase:** Simula la generación de PDFs sin invocar servicios nativos reales, devolviendo una ruta dummy
- **Spy DescargarComprobanteUseCase:** Rastrea las llamadas al use case de descarga manteniendo el comportamiento real de integración
- **Fake PermissionHandlerService:** Simula la concesión de permisos de almacenamiento para pruebas
- **Mock de Secure Storage Data Source:** Simula el almacenamiento y recuperación de tokens JWT

### Datos de Prueba

- **Tokens JWT válidos:** Generados dinámicamente con datos de prueba (nro_afiliado, circunscripción, etc.)
- **Respuestas de API de Login:** Simuladas con datos de usuario válidos y tokens de autenticación
- **Respuestas de Historial de Boletas:** Simuladas con boletas pagadas que incluyen fecha de pago
- **Comprobantes de Prueba:** Incluyen datos completos de comprobantes con boletas pagadas, montos de organismos, y referencias externas
- **Estados de autenticación:** Diferentes escenarios de usuario autenticado con validación de tokens

### Validaciones de UI

- **Presencia de widgets:** Verificación de que los elementos correctos estén visibles (pantallas, botones, textos)
- **Navegación entre pantallas:** Confirmación de transiciones correctas entre Login, Home, Boletas, Historial, y Comprobantes
- **Mensajes de éxito:** Validación de que se muestren los SnackBars apropiados tras operaciones exitosas
- **Estados de carga:** Verificación de indicadores de progreso durante operaciones asíncronas
- **Interacciones de usuario:** Simulación de toques, escritura en formularios, y selecciones en menús
- **Expansión de elementos:** Validación de la funcionalidad de ExpansionTiles en la pestaña de Juicios
- **Botones de acción:** Verificación de la funcionalidad de botones "Ver comprobante" y "DESCARGAR" en diferentes contextos

### Flujos de Descarga Específicos

#### Desde Boletas
- Autenticación de usuario
- Navegación a la pestaña de Boletas
- Carga y visualización del historial de boletas pagadas
- Acceso al detalle del comprobante mediante botón "Ver comprobante"
- Visualización de la pantalla de comprobante de inicio
- Descarga del PDF mediante botón "DESCARGAR"
- Verificación del SnackBar de éxito "Comprobante generado exitosamente"
- Validación de que el use case de descarga fue invocado correctamente

#### Desde Juicios
- Autenticación de usuario
- Navegación a la pestaña de Boletas
- Cambio a la pestaña de Juicios
- Carga y visualización de juicios disponibles
- Expansión de un juicio mediante ExpansionTile
- Acceso al detalle del comprobante mediante botón "Ver comprobante" (boleta de inicio)
- Visualización de la pantalla de comprobante de inicio
- Descarga del PDF mediante botón "DESCARGAR" y verificación del SnackBar de éxito
- Acceso al detalle del comprobante de fin mediante segundo botón "Ver comprobante" (si está disponible)
- Visualización de la pantalla de comprobante de fin
- Descarga del PDF de fin mediante botón "DESCARGAR" y verificación del SnackBar correspondiente

## Resultados

Las pruebas de integración del módulo de comprobantes proporcionan una validación completa del funcionamiento end-to-end, incluyendo:

- Verificación exhaustiva de flujos completos de descarga desde diferentes puntos de entrada (Boletas y Juicios).
- Validación de la integración entre el módulo de comprobantes y todos los demás módulos de la aplicación (autenticación, boletas, juicios).
- Simulación realista de interacciones de usuario y generación de comprobantes en formato PDF.
- Navegación correcta entre pantallas de comprobantes y verificación de estados.
- Validación de la generación y descarga de PDFs con verificación de que el use case de descarga es invocado correctamente.
- Verificación del comportamiento con diferentes tipos de comprobantes (boletas de inicio y fin).
- Pruebas de flujos alternativos desde diferentes módulos hasta la descarga de comprobantes.
- Validación de mensajes de éxito mediante SnackBars en diferentes escenarios.

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de comprobantes funciona correctamente en un entorno de integración completo y cumple con los requisitos de funcionalidad y experiencia de usuario esperados para la visualización, generación y descarga de comprobantes de pago.

