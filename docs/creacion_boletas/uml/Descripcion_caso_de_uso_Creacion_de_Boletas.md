# Descripción diagrama Caso de Uso - Módulo de inicio de sesión

**Actores principales**
* Afiliado: afiliado activo en la Caja con credenciales correspondientes.

**Actores secundarios**
* Sistema de la Caja: sistema que maneja la base de datos de la Caja.

# Descripción Casos de Uso

|                     **Caso de Uso**                       |                     **Descripción**                                        |
|:------------------------------------------------------|:--------------------------------------------------------------------------|
|Generar Boleta de Inicio de Juicio                      |El afiliado genera una Boleta de Inicio de Juicio, asociada a un juicio nuevo o existente |
|Generar boleta de fin de juicio                         |El afiliado genera una Boleta de Fin de Juicio vinculada a una boleta de inicio o juicio activo previamente registrado |
|Consultar historial de juicios                          |El afiliado visualiza el listado histórico de juicios, con acceso a los detalles, boletas vinculadas y estados de pago de las mismas |
|Consultar historial de boletas                          |El afiliado visualiza el listado histórico de boletas, con acceso a los detalles y estados de pago de las mismas |
|Pagar boleta                                            |Opcionalmente, el afiliado puede eligir pagar la boleta en el momento de crearla o en la busqueda del historial |
|Descargar boleta/comprobante                            |Opcionalmente, el afiliado puede eligir descargar la boleta que desee en la busqueda del historial |
|Almacenar juicio y boleta                               |El sistema registra la boleta en el sistema de la Caja, muestra la confirmación y actualiza el historial |
|Verificar boleta inicio de juicio                       |El sistema valida los datos y verifica la existencia de la boleta de inicio asociada |

# Casos de Uso principales y flujos
**Caso de uso:** Generar Boleta de Inicio de Juicio

**Descripción:**  
Permitir que un afiliado genere una Boleta de Inicio de Juicio, asociada a un juicio nuevo o existente, y registrarla en el sistema de la Caja.  

**Flujo principal:**
1. El afiliado selecciona la opción “Generar boleta de inicio de juicio” desde la pantalla principal.
2. El sistema muestra un formulario para completar datos del juicio y de pago.
3. El afiliado ingresa y confirma la información solicitada.
4. El sistema valida los datos ingresados.
5. El sistema registra la boleta en el sistema de la Caja.
6. Opcionalmente, el afiliado elige pagar la boleta en el momento.
7. El sistema muestra la confirmación y guarda la boleta en el historial del usuario.

**Flujo alternativos:**
- **A4:** Si los datos ingresados son incompletos o inválidos, el sistema muestra un mensaje de error y solicita corrección antes de continuar.
- **A5:** Si ocurre un error en el registro en el sistema de la Caja, se informa al afiliado y se cancela la operación.
- **A6:** Si el afiliado cancela el pago en línea, la boleta queda registrada pero en estado “pendiente de pago”.

**Precondiciones:**  
- El afiliado debe estar autenticado en la aplicación móvil.  
- El juicio, si es existente, debe estar registrado en el sistema.  

**Postcondiciones:**  
- La boleta y el juicio quedan registrados en el sistema de la Caja.
- El historial de boletas y juicios del afiliado se actualizan.

**Reglas de negocio:**  
- Los campos obligatorios deben estar completos y validados.
- El pago en línea es opcional en esta etapa.

---

**Caso de uso:** Generar Boleta de Fin de Juicio

**Descripción:**  
Permitir que un afiliado genere una Boleta de Fin de Juicio vinculada a una boleta de inicio o juicio activo previamente registrado.  

**Flujo principal:**
1. El afiliado selecciona la opción “Generar boleta de fin de juicio”.
2. El sistema solicita seleccionar un juicio activo o boleta de inicio existente.
3. El afiliado ingresa y confirma datos del juicio y de pago.
4. El sistema valida los datos y verifica la existencia de la boleta de inicio asociada.
5. El sistema registra la boleta en el sistema de la Caja.
6. Opcionalmente, el afiliado elige pagar la boleta en el momento.
7. El sistema muestra la confirmación y actualiza el historial.

**Flujo alternativos:**
- **A2:** Si no se encuentra un juicio activo o boleta de inicio vinculada, el sistema informa al afiliado y bloquea la operación.
- **A3:** Si los datos ingresados son incompletos o inválidos, el sistema muestra un mensaje de error y solicita corrección.
- **A5:** Si ocurre un error al registrar la boleta en el sistema de la Caja, se informa al afiliado y se cancela la operación.
- **A6:** Si el afiliado cancela el pago en línea, la boleta queda registrada pero en estado “pendiente de pago”.

**Precondiciones:**  
- El afiliado debe estar autenticado.  
- Debe existir una Boleta de Inicio vinculada al mismo juicio.

**Postcondiciones:**  
- La boleta y el juicio quedan registrados en el sistema de la Caja.
- El historial de boletas y juicios del afiliado se actualizan.

**Reglas de negocio:**  
- No se puede generar una boleta de fin sin boleta de inicio asociada.
- El pago en línea es opcional.

---

**Caso de uso:** Consultar historial de juicios

**Descripción:**  
Permitir que el afiliado visualice el listado histórico de juicios, con acceso a los detalles y estados de pago. Adicionalmente provee de funciones como son la creacion y el almacenamiento local de las boletas, como asi tambien el pago de las mismas. 

**Flujo principal:**
1. El afiliado selecciona “Historial” en la App.
2. El sistema obtiene del Sistema de la Caja la información de boletas vinculada a los juicios activos.
3. El afiliado selecciona entre los juicios generados, con la posibilidad de filtrar u ordenar la busqueda.
4. El sistema muestra el listado con detalles y estados.
5. Opcionalmente, el afiliado selecciona entre las funcionalidades de creacion de boleta de fin, de pago y de descarga de boletas.

**Flujo alternativos:**
- **A2:** Si no hay conexión con el sistema de la Caja, se informa al afiliado y se ofrece reintentar más tarde.
- **A3:** Si el afiliado no encuentra resultados según filtros aplicados, el sistema muestra mensaje de “sin coincidencias”.
- **A5:** Si el afiliado intenta crear una boleta de fin, pagar o descargar y la funcionalidad no está disponible, el sistema informa que la opción está en desarrollo o no habilitada.

**Precondiciones:**  
- El afiliado debe estar autenticado en la aplicación móvil.  

**Postcondiciones:**  
- El usuario puede visualizar y acceder a los detalles de boletas y juicios pasados.

---

**Caso de uso:** Consultar historial de boletas

**Descripción:**  
Permitir que el afiliado visualice el listado histórico de boletas, con acceso a los detalles y estados de pago. Adicionalmente provee de funciones como son la descarga para almacenamiento local de las boletas y comprobantes de pagos, como asi tambien efectuar el pago de las mismas. 

**Flujo principal:**
1. El afiliado selecciona “Historial” en la App.
2. El sistema obtiene del Sistema de la Caja la información de boletas vinculada a los juicios activos.
3. El afiliado selecciona entre los juicios generados, con la posibilidad de filtrar u ordenar la busqueda.
4. El sistema muestra el listado con detalles y estados.
5. Opcionalmente, el afiliado selecciona entre las funcionalidades de pago de boletas y de descarga de boletas o comprobantes.

**Flujo alternativos:**
- **A2:** Si no hay conexión con el sistema de la Caja, se informa al afiliado y se ofrece reintentar más tarde.
- **A3:** Si el afiliado no encuentra resultados según filtros aplicados, el sistema muestra mensaje de “sin coincidencias”.
- **A5:** Si la boleta seleccionada no está disponible para descarga o pago (ej: vencida, no registrada correctamente), el sistema informa el motivo y bloquea la acción.

**Precondiciones:**  
- El afiliado debe estar autenticado en la aplicación móvil.  

**Postcondiciones:**  
- El usuario puede visualizar y acceder a los detalles de boletas y juicios pasados.

---

**Caso de uso:** Pagar Boleta

**Descripción:**  
Permitir que el afiliado realice el pago de una boleta, ya sea al momento de generarla o posteriormente desde el historial.

**Flujo principal:**
1. El afiliado selecciona una boleta pendiente de pago (desde su creación o historial).
2. El sistema muestra los medios de pago disponibles.
3. El afiliado elige un medio de pago y confirma la operación.
4. El sistema redirige a la pasarela de pagos.
5. La pasarela procesa la transacción y devuelve la respuesta.
6. El sistema registra el resultado y actualiza el estado de la boleta.
7. El sistema muestra la confirmación al afiliado.

**Flujo alternativos:**
- **A4:** Si el afiliado cancela antes de confirmar, la operación se anula y la boleta queda en estado pendiente.
- **A5:** Si la pasarela rechaza el pago, el sistema informa el error y mantiene la boleta pendiente.

**Precondiciones:**  
- El afiliado debe estar autenticado en la aplicación móvil.
- Debe existir una boleta generada y disponible para pago.

**Postcondiciones:**  
- Si el pago fue exitoso, la boleta queda registrada como pagada y visible en el historial con comprobante.
- Si el pago falla, el estado permanece como pendiente.

**Reglas de negocio:**
- Sólo pueden pagarse boletas pendientes de pago.
- El sistema debe garantizar la trazabilidad de cada transacción.

---

**Caso de uso:** Descargar Boleta/Comprobante

**Descripción:**  
Permitir que el afiliado descargue en formato digital una boleta o comprobante de pago para almacenarlo o imprimirlo.

**Flujo principal:**
1. El afiliado selecciona una boleta o comprobante desde el historial.  
2. El sistema genera o recupera el archivo digital correspondiente.  
3. El sistema ofrece la opción de descargar o visualizar el documento.  
4. El afiliado descarga o guarda el archivo en su dispositivo.  

**Flujo alternativos:**
- **A2:** Si el documento no está disponible, el sistema informa al afiliado y ofrece reintentar más tarde.  

**Precondiciones:**  
- El afiliado debe estar autenticado en la aplicación móvil.
- Debe existir una boleta generada o pagada disponible en el historial.

**Postcondiciones:**  
- El afiliado dispone de la boleta o comprobante en formato digital en su dispositivo.  

**Reglas de negocio:**
- Los comprobantes de pago sólo están disponibles si la boleta fue efectivamente pagada.  
- El formato de exportación debe garantizar validez y legibilidad (ej: PDF). 

---

**Caso de uso:** Almacenar Juicio y Boleta  

**Descripción:**  
Registrar en el sistema central de la Caja la información del juicio y la boleta generada, y actualizar el historial del afiliado.  

**Flujo principal:**
1. El sistema valida la información de la boleta y del juicio.  
2. El sistema registra los datos en la base de la Caja.  
3. El sistema confirma la operación.  
4. El sistema actualiza el historial disponible en la aplicación. 

**Flujo alternativos:**
- **A1:** Si los datos no cumplen validaciones, el sistema informa al afiliado y solicita correcciones.  
- **A2:** Si ocurre un error en el registro, el sistema informa al afiliado y cancela la operación.  

**Precondiciones:**  
- El afiliado debe haber ingresado los datos requeridos en la generación de una boleta.  

**Postcondiciones:**  
- La boleta y el juicio quedan almacenados en el sistema central de la Caja.  
- El historial del afiliado se actualiza automáticamente.  

**Reglas de negocio:**
- No se debe permitir el registro de boletas incompletas o con datos inválidos.  
- Cada operación debe quedar trazada en el sistema central.  

---

## Caso de uso: Verificar Boleta de Inicio de Juicio  
**Descripción:**  
Comprobar, al generar una Boleta de Fin de Juicio, que exista previamente una Boleta de Inicio asociada al mismo juicio.  

**Flujo principal:**  
1. El sistema recibe los datos del juicio asociados a la boleta de fin.  
2. El sistema consulta la base de datos para verificar la existencia de una boleta de inicio vinculada.  
3. El sistema valida la correspondencia y autoriza la operación.  

**Flujos alternativos:**  
- **A2:** Si no existe una boleta de inicio asociada, el sistema informa al afiliado y bloquea la creación.  
- **A3:** Si los datos ingresados no coinciden con un juicio activo, el sistema informa error y solicita corrección.  

**Precondiciones:**  
- El afiliado debe haber solicitado la creación de una Boleta de Fin de Juicio.  

**Postcondiciones:**  
- Si la verificación es exitosa, el sistema permite registrar la boleta de fin.  
- Si la verificación falla, la creación se interrumpe.  

**Reglas de negocio:**  
- No puede existir una boleta de fin sin una boleta de inicio previamente registrada para el mismo juicio.  

![Diagrama](/docs/creacion_boletas/uml/CU_Modulo_de_creacion_de_boletas.png)