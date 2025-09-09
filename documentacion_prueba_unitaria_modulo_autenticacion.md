## Pruebas Unitarias

### Objetivo
El objetivo principal de las pruebas unitarias es garantizar el correcto funcionamiento de los componentes individuales de la aplicación, tales como clases, providers y repositorios. Estas pruebas permiten detectar errores de forma temprana en el ciclo de desarrollo, asegurando que cada unidad de código cumpla con su responsabilidad de manera aislada, sin depender de otros módulos.

### Herramientas utilizadas
Para la implementación de las pruebas unitarias se utilizaron las siguientes herramientas:

- `flutter_test`: Proporciona un conjunto de utilidades y funciones para crear y ejecutar pruebas unitarias en aplicaciones Flutter, permitiendo validar el comportamiento de widgets, clases y lógica de negocio de manera aislada.
- `mockito`: Permite simular dependencias externas, como APIs, bases de datos o servicios de almacenamiento, lo que facilita probar los componentes de manera controlada sin depender de recursos reales. Esto asegura que las pruebas sean reproducibles y predecibles.

El uso combinado de estas herramientas permite garantizar la calidad del código, detectar errores de forma temprana y mantener un flujo de desarrollo más seguro y eficiente.

### Alcance

#### Total de Pruebas por Capa
- **Capa de Datos:** 47 pruebas
- **Capa de Dominio:** 16 pruebas
- **Capa de Presentación:** 25 pruebas
- **Total:** 88 pruebas unitarias

#### Funcionalidades Cubiertas
- Autenticación de usuarios
- Recuperación de contraseña
- Cambio de contraseña
- Verificación de estado de autenticación
- Gestión de preferencias de biometría
- Almacenamiento seguro de tokens
- Validación de formularios
- Manejo de errores y excepciones
- Estados de carga y éxito/error

#### Casos de Error Cubiertos
- Errores de conexión (timeout, socket)
- Errores de autenticación (credenciales incorrectas)
- Errores de almacenamiento (permisos, disponibilidad)
- Errores de servidor (500, HTML inesperado)
- Errores de validación (campos requeridos, longitud mínima)
- Errores de biometría (no disponible, bloqueado, cancelado)

### Resultados
Las pruebas unitarias del módulo de autenticación proporcionan una cobertura completa de todas las funcionalidades críticas, incluyendo:

- Validación exhaustiva de la lógica de negocio en cada capa.
- Manejo robusto de errores con casos específicos para cada tipo de excepción.
- Simulación completa de dependencias externas usando Mockito.
- Verificación de estados y transiciones en los providers.
- Validación de formularios con casos de éxito y error.

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de autenticación cumple con los requisitos de calidad y funcionalidad esperados.
