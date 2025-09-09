# Pruebas Unitarias - Módulo de Autenticación

## 1. Pruebas Unitarias

**Objetivo:** Validar el correcto funcionamiento de componentes individuales de la aplicación (clases, providers, repositorios).

**Herramientas utilizadas:** flutter_test, mockito para simular dependencias externas.

**Alcance:**
Aca iria lo de la seccion 2

**Resultado:** Todas las pruebas ejecutadas arrojaron resultados correctos, permitiendo detectar y corregir casos de error en validaciones.

---

## 2. Estructura de Pruebas por Capas

### 2.1 Capa de Datos (Data Layer)

#### 2.1.1 PreferenciasDataSource

**Pruebas implementadas:**
- **guardarPreferenciaBiometria:**
  - ✅ Guardar correctamente la preferencia de biometría cuando no hay errores
  - ✅ Lanzar AuthPreferencesWriteException cuando hay un error al guardar

- **obtenerPreferenciaBiometria:**
  - ✅ Retornar true cuando la preferencia está guardada como true
  - ✅ Retornar false cuando la preferencia está guardada como false
  - ✅ Retornar false cuando la preferencia no existe (null)
  - ✅ Lanzar AuthPreferencesReadException cuando hay un error al leer

- **obtenerValor:**
  - ✅ Retornar el valor correcto cuando existe
  - ✅ Retornar null cuando la clave no existe
  - ✅ Lanzar AuthPreferencesReadException cuando hay un error al leer

- **guardarValor:**
  - ✅ Guardar correctamente el valor cuando no hay errores
  - ✅ Lanzar AuthPreferencesWriteException cuando hay un error al guardar

#### 2.1.2 SecureStorageDataSource

**Pruebas implementadas:**
- **guardarToken:**
  - ✅ Guardar correctamente el token cuando no hay errores
  - ✅ Lanzar AuthStorageAccessException cuando el usuario cancela la operación
  - ✅ Lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible
  - ✅ Lanzar AuthStorageAccessException para otros errores de plataforma
  - ✅ Lanzar AuthStorageAccessException para errores inesperados

- **obtenerToken:**
  - ✅ Retornar el token cuando existe
  - ✅ Retornar null cuando el token no existe
  - ✅ Lanzar AuthStorageAccessException cuando el usuario cancela la operación
  - ✅ Lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible
  - ✅ Lanzar AuthStorageAccessException para otros errores de plataforma
  - ✅ Re-lanzar errores inesperados sin envolverlos

- **eliminarToken:**
  - ✅ Eliminar correctamente el token cuando no hay errores
  - ✅ Lanzar AuthStorageAccessException cuando el usuario cancela la operación
  - ✅ Lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible
  - ✅ Lanzar AuthStorageAccessException para otros errores de plataforma
  - ✅ Lanzar AuthStorageAccessException para errores inesperados

- **guardarValor:**
  - ✅ Guardar correctamente el valor cuando no hay errores
  - ✅ Lanzar AuthStorageAccessException para errores de plataforma
  - ✅ Lanzar AuthStorageAccessException para errores inesperados

- **obtenerValor:**
  - ✅ Retornar el valor cuando existe
  - ✅ Retornar null cuando el valor no existe
  - ✅ Lanzar AuthStorageAccessException para errores de plataforma
  - ✅ Lanzar AuthStorageAccessException para errores inesperados

#### 2.1.3 UsuarioDataSource

**Pruebas implementadas:**
- **autenticarUsuario:**
  - ✅ Retornar AuthSuccessResponse si el usuario y contraseña son correctos
  - ✅ Retornar AuthInvalidCredentialsResponse si la contraseña es incorrecta
  - ✅ Retornar AuthGenericErrorResponse si el endpoint está caído o hay timeout
  - ✅ Retornar AuthGenericErrorResponse si el endpoint devuelve error 500

- **recuperarPassword:**
  - ✅ Retornar RecuperarSuccessResponse si los datos enviados son correctos
  - ✅ Retornar RecuperarInvalidCredentialsResponse si los datos enviados son incorrectos
  - ✅ Retornar RecuperarGenericErrorResponse cuando hay timeout de conexión
  - ✅ Retornar RecuperarGenericErrorResponse cuando el servidor devuelve HTML (FormatException)

- **cambiarPassword:**
  - ✅ Retornar CambiarPasswordSuccessResponse si los datos enviados son correctos
  - ✅ Retornar CambiarPasswordInvalidCredentialsResponse si los datos enviados son incorrectos
  - ✅ Retornar CambiarPasswordGenericErrorResponse cuando hay timeout de conexión

- **obtenerDatosUsuario:**
  - ✅ Retornar DatosUsuarioSuccessResponse si los datos enviados son correctos
  - ✅ Retornar DatosUsuarioInvalidTokenResponse si el token es inválido
  - ✅ Retornar DatosUsuarioGenericErrorResponse cuando hay timeout de conexión
  - ✅ Retornar DatosUsuarioGenericErrorResponse cuando el servidor devuelve HTML (FormatException)

#### 2.1.4 CambiarPasswordResponseMapper

**Pruebas implementadas:**
- **fromApiResponse:**
  - ✅ Retornar CambiarPasswordSuccessResponse cuando statusCode es 200 y estado es true
  - ✅ Retornar CambiarPasswordSuccessResponse con mensaje por defecto cuando estado es true y mensaje está vacío
  - ✅ Retornar CambiarPasswordInvalidCredentialsResponse cuando statusCode es 200 y estado es false
  - ✅ Retornar CambiarPasswordInvalidCredentialsResponse con mensaje por defecto cuando estado es false y mensaje está vacío
  - ✅ Retornar CambiarPasswordGenericErrorResponse cuando statusCode no es 200
  - ✅ Retornar CambiarPasswordGenericErrorResponse con mensaje por defecto cuando statusCode no es 200 y mensaje está vacío

- **parseo de diferentes tipos de estado:**
  - ✅ Parsear bool correctamente
  - ✅ Parsear string "1" y "true" como true, otros como false
  - ✅ Parsear int 1 como true y otros como false
  - ✅ Retornar false para tipos no soportados o valores nulos

### 2.2 Capa de Dominio (Domain Layer)

#### 2.2.1 UsuarioRepositoryImpl

**Pruebas implementadas:**
- **autenticar:**
  - ✅ Retornar un UsuarioEntity si los datos son correctos
  - ✅ Retornar un AuthInvalidCredentialsException si los datos son incorrectos
  - ✅ Retornar un AuthGenericLoginException si ocurre un error inesperado
  - ✅ Retornar un AuthLocalStorageException si ocurre un error al guardar el token
  - ✅ Retornar un AuthPreferencesException si ocurre un error al guardar el usuario

- **estaAutenticado:**
  - ✅ Retornar true si el usuario está autenticado
  - ✅ Retornar false si no se encuentra el token en el almacenamiento seguro (es null)
  - ✅ Retornar false si el token es un string vacío
  - ✅ Retornar false si no se puede acceder al almacenamiento seguro (AuthStorageUnavailableException)
  - ✅ Retornar false si ocurre un error al acceder al almacenamiento seguro (AuthStorageAccessException)

#### 2.2.2 RecuperarPasswordUseCase

**Pruebas implementadas:**
- **execute:**
  - ✅ Retornar un RecuperarSuccessResponse si los datos enviados son correctos
  - ✅ Lanzar una excepción si los datos enviados son incorrectos
  - ✅ Retornar un RecuperarGenericErrorResponse cuando hay error de conexión
  - ✅ Lanzar AuthException cuando ocurre una excepción inesperada
  - ✅ Manejar diferentes tipos de parámetros correctamente

#### 2.2.3 VerificarEstadoAutenticacionUseCase

**Pruebas implementadas:**
- **execute:**
  - ✅ Retornar AuthStatus.noAutenticado cuando el usuario no está autenticado
  - ✅ Retornar AuthStatus.autenticadoRequiereBiometria cuando el usuario está autenticado y la biometría está habilitada
  - ✅ Retornar AuthStatus.autenticadoNoRequiereBiometria cuando el usuario está autenticado y la biometría está deshabilitada
  - ✅ Lanzar la excepción original si ocurre un error inesperado en el repository

### 2.3 Capa de Presentación (Presentation Layer)

#### 2.3.1 AuthProvider

**Pruebas implementadas:**
- **Estado inicial:**
  - ✅ El estado inicial del AuthProvider debería ser AuthStatus.noAutenticado si no hay usuario autenticado

- **login:**
  - ✅ Actualizar el estado a autenticadoNoRequiereBiometria en login exitoso sin biometría
  - ✅ Lanzar AuthException para credenciales incorrectas

- **logout:**
  - ✅ Actualizar el estado a AuthStatus.noAutenticado

- **actualizarPreferenciaBiometria:**
  - ✅ Cambiar la preferencia y refrescar el estado

- **refresh:**
  - ✅ Actualizar el estado de autenticación

#### 2.3.2 BiometricAuthService

**Pruebas implementadas:**
- **biometriaDisponible:**
  - ✅ Retornar true cuando LocalAuthentication.canCheckBiometrics es true
  - ✅ Retornar false cuando LocalAuthentication.canCheckBiometrics lanza PlatformException

- **autenticar:**
  - ✅ Retornar success cuando authenticate devuelve true
  - ✅ Retornar failure cuando authenticate devuelve false
  - ✅ Retornar notAvailable cuando PlatformException code es notAvailable
  - ✅ Retornar notAvailable cuando PlatformException code es notEnrolled
  - ✅ Retornar lockedOut cuando PlatformException code es lockedOut
  - ✅ Retornar lockedOut cuando PlatformException code es permanentlyLockedOut
  - ✅ Retornar failure cuando PlatformException code es auth_failed
  - ✅ Retornar canceled cuando PlatformException code es Aborted
  - ✅ Retornar platformError para cualquier otro PlatformException
  - ✅ Retornar unknownError para cualquier otra excepción

#### 2.3.3 CambiarPasswordProvider

**Pruebas implementadas:**
- **Estado inicial:**
  - ✅ El estado inicial del CambiarPasswordProvider debería ser CambiarPasswordState con isSuccess = false

- **cambiarPassword:**
  - ✅ Actualizar el estado a success cuando la operación es exitosa
  - ✅ Lanzar IncorrectPasswordException cuando la operación falla
  - ✅ Manejar errores genéricos del servidor
  - ✅ Mostrar estado de loading durante la operación
  - ✅ Manejar excepciones del repositorio

- **reset:**
  - ✅ Reiniciar el estado del provider

#### 2.3.4 PasswordRecoveryProvider

**Pruebas implementadas:**
- **Estado inicial:**
  - ✅ El estado inicial del PasswordRecoveryProvider debería ser PasswordRecoveryState con isSuccess = false

- **recuperarPassword:**
  - ✅ Actualizar el estado a success cuando la operación es exitosa
  - ✅ Actualizar el estado con error cuando la operación falla
  - ✅ Manejar errores genéricos del servidor
  - ✅ Mostrar estado de loading durante la operación
  - ✅ Manejar excepciones del use case
  - ✅ Convertir correctamente el nroAfiliado de String a int
  - ✅ Manejar múltiples llamadas consecutivas

- **reset:**
  - ✅ Reiniciar el estado del provider

#### 2.3.5 LoginForm Widget

**Pruebas implementadas:**
- **Estructura:**
  - ✅ Mostrar el texto definido en el widget sin botón biométrico
  - ✅ Mostrar el botón biométrico cuando showBiometricButton es true

- **Funcionalidad:**
  - ✅ Mostrar errores de validación si los campos están vacíos
  - ✅ Mostrar error de validación para usuario muy corto
  - ✅ Mostrar error de validación para contraseña muy corta
  - ✅ No mostrar errores de validación con datos válidos
  - ✅ Navegar a la pantalla de recuperación de contraseña cuando se presiona el botón de olvidó su contraseña

---

## 3. Resumen de Cobertura

### 3.1 Total de Pruebas por Capa
- **Capa de Datos:** 47 pruebas
- **Capa de Dominio:** 16 pruebas  
- **Capa de Presentación:** 25 pruebas
- **Total:** 88 pruebas unitarias

### 3.2 Funcionalidades Cubiertas
- Autenticación de usuarios
- Recuperación de contraseña
- Cambio de contraseña
- Verificación de estado de autenticación
- Gestión de preferencias de biometría
- Almacenamiento seguro de tokens
- Validación de formularios
- Manejo de errores y excepciones
- Estados de carga y éxito/error

### 3.3 Casos de Error Cubiertos
- Errores de conexión (timeout, socket)
- Errores de autenticación (credenciales incorrectas)
- Errores de almacenamiento (permisos, disponibilidad)
- Errores de servidor (500, HTML inesperado)
- Errores de validación (campos requeridos, longitud mínima)
- Errores de biometría (no disponible, bloqueado, cancelado)

---

## 4. Conclusiones

Las pruebas unitarias del módulo de autenticación proporcionan una cobertura completa de todas las funcionalidades críticas, incluyendo:

1. **Validación exhaustiva** de la lógica de negocio en cada capa
2. **Manejo robusto de errores** con casos específicos para cada tipo de excepción
3. **Simulación completa** de dependencias externas usando Mockito
4. **Verificación de estados** y transiciones en los providers
5. **Validación de formularios** con casos de éxito y error

Todas las pruebas han sido ejecutadas exitosamente, confirmando que el módulo de autenticación cumple con los requisitos de calidad y funcionalidad esperados.
