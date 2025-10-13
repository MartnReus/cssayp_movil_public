# Definición de estados de error y mensajes correspondientes - Módulo de Pagos

Este documento tiene como objetivo listar y detallar los errores, validaciones, respuestas y mensajes correspondientes a las funcionalidades del módulo 3 (Pagos de Boletas).

## Estados de error y mensajes para la funcionalidad de pago con tarjeta (PayWay)

### Errores de validación de formulario

|    **Validación**             |          **Condición**                    |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|Campo nombre vacío            |Nombre es null o vacío                     |"El nombre es requerido"|
|Longitud mínima nombre        |Nombre tiene menos de 2 caracteres         |"El nombre debe tener al menos 2 caracteres"|
|Campo DNI vacío               |DNI es null o vacío                        |"El DNI es requerido"|
|Formato DNI inválido          |DNI no tiene 7 u 8 dígitos                 |"El DNI debe tener 7 u 8 dígitos"|
|Campo número de tarjeta vacío |Número de tarjeta es null o vacío          |"El número de tarjeta es requerido"|
|Formato número de tarjeta inválido|Número no tiene entre 13 y 19 dígitos    |"Número de tarjeta inválido"|
|Algoritmo Luhn fallido        |Número de tarjeta no pasa validación Luhn  |"Número de tarjeta inválido"|
|Campo CVV vacío               |CVV es null o vacío                        |"El CVV es requerido"|
|Formato CVV inválido          |CVV no tiene 3 o 4 dígitos                 |"El CVV debe tener 3 o 4 dígitos"|
|Campo fecha expiración vacío  |Fecha de expiración es null o vacía        |"La fecha de expiración es requerida"|
|Formato fecha inválido        |No cumple formato MM/YY                    |"Formato inválido (MM/YY)"|
|Tarjeta vencida               |Fecha de expiración es anterior a la actual|"La tarjeta está vencida"|
|Fecha inválida                |Fecha no es numérica válida                |"Fecha inválida"|

### Errores de procesamiento de pago

|    **Código de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_PAYMENT_PROCESSING`      |Error al procesar el pago                  |"Error al procesar el pago"|
|`ERR_INVALID_CARD_DATA`       |Datos de tarjeta inválidos                 |"Por favor complete todos los campos correctamente"|
|`ERR_PAYMENT_DECLINED`        |Pago rechazado por el banco                |"El pago fue rechazado. Verifique los datos de su tarjeta"|
|`ERR_INSUFFICIENT_FUNDS`      |Fondos insuficientes                       |"Fondos insuficientes en la tarjeta"|
|`ERR_CARD_EXPIRED`            |Tarjeta vencida                            |"La tarjeta ha expirado"|
|`ERR_INVALID_CVV`             |CVV incorrecto                             |"El código de seguridad es incorrecto"|
|`ERR_CARD_BLOCKED`            |Tarjeta bloqueada                          |"La tarjeta está bloqueada. Contacte a su banco"|

### Errores de red y servidor

|    **Tipo de Excepción**     |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`SocketException`              |No hay conexión a Internet               |"Error en la conexión con el servidor"|
|`TimeoutException`             |Timeout en la conexión                    |"Error en la conexión con el servidor"|
|`FormatException`              |Error en el formato de respuesta          |"Error del servidor, intente nuevamente más tarde"|
|Error genérico                 |Error inesperado                          |"Error inesperado al procesar el pago"|

### Respuestas del servidor PayWay

|    **Código HTTP**           |          **Tipo de Respuesta**            |             **Descripción**                                  |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`201`                         |`PaymentSuccess`                           |Pago exitoso - Transacción completada|
|`400`                         |`PaymentError`                             |Datos incorrectos - Mensaje específico del servidor|
|`401`                         |`PaymentError`                             |No autorizado - Credenciales inválidas|
|`402`                         |`PaymentError`                             |Pago requerido - Error de procesamiento|
|`403`                         |`PaymentError`                             |Prohibido - Tarjeta no permitida|
|`404`                         |`PaymentError`                             |No encontrado - Servicio no disponible|
|`500`                         |`PaymentError`                             |Error del servidor - Mensaje genérico|
|`0`                           |`PaymentError`                             |Error de conexión - Sin respuesta del servidor|

## Estados de error y mensajes para la funcionalidad de pago con Red Link

### Errores de generación de URL de pago

|    **Código de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_URL_GENERATION`          |Error al generar URL de pago               |"Error al generar URL de pago"|
|`ERR_RED_LINK_UNAVAILABLE`    |Servicio Red Link no disponible            |"El servicio de pago no está disponible"|
|`ERR_INVALID_BOLETA`          |Boleta inválida para Red Link              |"Red Link solo está disponible para una boleta de inicio"|
|`ERR_PAYMENT_INIT_FAILED`     |Fallo al inicializar pago                  |"Error al iniciar pago con Red Link"|

### Errores de monitoreo de pago

|    **Código de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_PAYMENT_MONITORING`      |Error al monitorear pago                   |"Error al monitorear pago"|
|`ERR_PAYMENT_TIMEOUT`         |Timeout en el monitoreo                    |"Tiempo de espera agotado. Verifique el estado del pago"|
|`ERR_PAYMENT_VERIFICATION`    |Error al verificar estado                  |"Error al verificar estado"|
|`ERR_CONNECTION_LOST`         |Conexión perdida durante monitoreo         |"Error de conexión al verificar estado del pago"|

### Errores de carga de página web

|    **Código de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_WEB_RESOURCE`            |Error de recurso web                       |"Error al cargar la página"|
|`ERR_JAVASCRIPT_EXECUTION`    |Error de ejecución JavaScript              |"Error desconocido"|
|`ERR_WEB_NAVIGATION`          |Error de navegación web                    |"Error al abrir Red Link"|

### Errores de red y servidor Red Link

|    **Tipo de Excepción**     |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`SocketException`              |No hay conexión a Internet               |"Error en la conexión con el servidor"|
|`TimeoutException`             |Timeout en la conexión                    |"Error en la conexión con el servidor"|
|`FormatException`              |Error en el formato de respuesta          |"Error del servidor, intente nuevamente más tarde"|
|Error genérico                 |Error inesperado                          |"Error inesperado"|

### Respuestas del servidor Red Link

|    **Código HTTP**           |          **Tipo de Respuesta**            |             **Descripción**                                  |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`200`                         |`RedLinkPaymentResponseModel`              |URL generada exitosamente - success: true|
|`400`                         |`RedLinkPaymentResponseModel`              |Datos incorrectos - success: false, error específico|
|`500`                         |`RedLinkPaymentResponseModel`              |Error del servidor - success: false, error genérico|
|`0`                           |`RedLinkPaymentResponseModel`              |Error de conexión - success: false, error de conexión|

### Estados de monitoreo de pago

|    **Estado**                |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`PAYMENT_PENDING`             |Pago pendiente                             |"Esperando confirmación del pago..."|
|`PAYMENT_SUCCESS`             |Pago exitoso                               |"Pago realizado exitosamente"|
|`PAYMENT_FAILED`              |Pago fallido                               |Mensaje específico del servidor|
|`PAYMENT_TIMEOUT`             |Timeout del pago                           |"Tiempo de espera agotado"|

## Estados de error y mensajes para la funcionalidad de selección de método de pago

### Errores de validación de boletas

|    **Validación**             |          **Condición**                    |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|Lista de boletas vacía        |No hay boletas seleccionadas               |"Debe seleccionar al menos una boleta"|
|Boleta inválida               |Boleta con datos incorrectos               |"Los datos de la boleta son inválidos"|
|Monto inválido                |Monto menor o igual a cero                 |"El monto debe ser mayor a cero"|
|Múltiples boletas Red Link    |Más de una boleta para Red Link            |"Red Link solo está disponible para una boleta"|

### Errores de procesamiento general

|    **Código de Error**      |          **Tipo de Error**                |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`ERR_NO_PAYMENT_METHOD`       |No se seleccionó método de pago            |"Debe seleccionar un método de pago"|
|`ERR_PAYMENT_METHOD_UNAVAILABLE`|Método de pago no disponible              |"El método de pago seleccionado no está disponible"|
|`ERR_INVALID_BOLETA_DATA`     |Datos de boleta inválidos                  |"Los datos de la boleta son inválidos"|
|`ERR_PAYMENT_CANCELLED`       |Usuario canceló el pago                    |N/A - No se muestra mensaje|

## Mensajes de estado del sistema

### Estados de carga

|    **Estado**                |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`PAYMENT_LOADING`             |Procesando pago                            |"Procesando pago..."|
|`PAYMENT_LOADING_PAYWAY`      |Procesando con PayWay                      |"Procesando pago con tarjeta..."|
|`PAYMENT_LOADING_REDLINK`     |Generando URL Red Link                     |"Generando URL de pago..."|
|`PAYMENT_LOADING_REDLINK_OPEN`|Abriendo Red Link                          |"URL de pago generada. Abriendo Red Link..."|
|`PAYMENT_LOADING_MONITORING`  |Monitoreando pago                          |"Esperando confirmación del pago..."|

### Estados de éxito

|    **Estado**                |          **Descripción**                  |             **Mensaje para el usuario**                      |
|:-----------------------------|:------------------------------------------|:-------------------------------------------------------------|
|`PAYMENT_SUCCESS`             |Pago exitoso                               |"Pago realizado exitosamente"|
|`PAYMENT_SUCCESS_PAYWAY`      |Pago exitoso con PayWay                    |"Pago con tarjeta realizado exitosamente"|
|`PAYMENT_SUCCESS_REDLINK`     |Pago exitoso con Red Link                  |"Pago con Red Link realizado exitosamente"|
