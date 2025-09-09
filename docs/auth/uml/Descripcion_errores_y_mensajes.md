# Definición de estados de error y mensajes correspondientes

Este documento tiene como objetivo listar y detallar los errores, validaciones, respuestas y mensajes correspondientes a las funcionalidades del modulo 1.

## Estados de error y mensajes para la funcionalidad de inicio de sesion

### Errores de autenticación

|    **Código  de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_INVALID_CREDENTIALS`       |Usuario o contraseña incorrectos         |"Datos incorrectos"|
|`ERR_UNEXPECTED_LOGIN`          |Error inesperado o sin clasificar        |"No se pudo establecer conexión. Verifique su red e intente nuevamente"|

### Errores de almacenamiento local

|    **Código  de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_STORAGE_ACCESS`           |Error al acceder al almacenamiento seguro |N/A - No se muestra mensaje|
|`ERR_STORAGE_UNAVAILABLE`      |Almacenamiento seguro no disponible       |N/A - No se muestra mensaje|

### Errores de preferencias

|    **Código  de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_PREFERENCES_ACCESS`       |Error al acceder a las preferencias       |N/A - No se muestra mensaje|
|`ERR_PREFERENCES_WRITE`        |Error al escribir en las preferencias     |N/A - No se muestra mensaje|
|`ERR_PREFERENCES_READ`         |Error al leer las preferencias            |N/A - No se muestra mensaje|

### Errores de biometría 

|    **Código  de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`BIOMETRIC_SUCCESS`            |Autenticación biométrica exitosa           |N/A - Redirige al usuario|
|`BIOMETRIC_FAILURE`            |No se reconoció huella digital o rostro   |"No se pudo reconocer su biometría. Intente nuevamente"|
|`BIOMETRIC_NOT_AVAILABLE`     |El dispositivo no admite biometría        |"La autenticación biométrica no está disponible en este dispositivo"|
|`BIOMETRIC_LOCKED_OUT`        |Biometría bloqueada temporalmente         |"Demasiados intentos fallidos. Intente más tarde"|
|`BIOMETRIC_CANCELED`          |Usuario canceló la autenticación          |N/A - No se muestra mensaje|
|`BIOMETRIC_PLATFORM_ERROR`    |Error de plataforma en biometría          |"Error en la autenticación biométrica"|
|`BIOMETRIC_UNKNOWN_ERROR`     |Error desconocido en biometría            |"Error inesperado en la autenticación biométrica"|

### Validaciones del formulario

|    **Validación**             |          **Condición**                    |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|Campo usuario vacío            |Usuario es null o vacío                    |"El usuario es requerido"|
|Longitud mínima usuario        |Usuario tiene menos de 3 caracteres       |"El usuario debe tener al menos 3 caracteres"|
|Campo contraseña vacío         |Contraseña es null o vacía                |"La contraseña es requerida"|
|Longitud mínima contraseña     |Contraseña tiene menos de 4 caracteres    |"La contraseña debe tener al menos 4 caracteres"|

### Errores de red y servidor

|    **Tipo de Excepción**     |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`SocketException`              |No hay conexión a Internet               |"Error en la conexión con el servidor"|
|`TimeoutException`             |Timeout en la conexión                    |"Error en la conexión con el servidor"|
|`FormatException`              |Error en el formato de respuesta          |"Error del servidor, intente nuevamente más tarde"|
|Error genérico                 |Error inesperado                          |"Error inesperado al autenticar usuario"|

## Estados de error y mensajes para la funcionalidad de recuperacion de contraseña

### Errores de autenticación

|    **Código  de Error**      |          **Tipo de Error**                             |             **Mensaje para el usuario**                      |
|:-----------------------------|:-------------------------------------------------------|:-------------------------------------------------------------|
|`ERR_INVALID_CREDENTIALS`     |Los datos enviados son incorrectos                     |"Datos incorrectos"|
|`ERR_UNEXPECTED_PASS_RECOVERY` |Error inesperado o sin clasificar                       |"Error inesperado del sistema"|

### Validaciones del formulario

|    **Validación**             |          **Condición**                    |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|Número de afiliado vacío       |Campo es null o vacío                      |"El número de afiliado es requerido"|
|Número de afiliado no numérico |Contiene caracteres no numéricos           |"Solo se permiten números"|
|Número de afiliado muy largo   |Tiene más de 5 dígitos                     |"Máximo 5 dígitos"|
|Número de documento vacío      |Campo es null o vacío                      |"El número de documento es requerido"|
|Número de documento no numérico|Contiene caracteres no numéricos           |"Solo se permiten números"|
|Número de documento inválido   |No tiene entre 7 y 8 dígitos               |"El número de documento debe tener entre 7 y 8 dígitos"|
|Email vacío                    |Campo es null o vacío                      |"El correo electrónico es requerido"|
|Email inválido                |No cumple formato de email válido          |"Ingrese un correo electrónico válido"|

### Errores de red y servidor

|    **Tipo de Excepción**     |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`SocketException`              |No hay conexión a Internet               |"Error en la conexión con el servidor"|
|`TimeoutException`             |Timeout en la conexión                    |"Error en la conexión con el servidor"|
|`FormatException`              |Error en el formato de respuesta          |"Error del servidor, intente nuevamente más tarde"|
|Error genérico                 |Error inesperado                          |"Error inesperado al recuperar contraseña"|

### Respuestas del servidor

|    **Código HTTP**           |          **Tipo de Respuesta**            |             **Descripción**                                  |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`200`                         |`RecuperarSuccessResponse`                 |Recuperación exitosa - Se envía email con contraseña temporal|
|`400`                         |`RecuperarInvalidCredentialsResponse`      |Datos incorrectos - Mensaje específico del servidor|
|`500`                         |`RecuperarGenericErrorResponse`            |Error del servidor - Mensaje genérico|
|`0`                           |`RecuperarGenericErrorResponse`            |Error de conexión - Sin respuesta del servidor|