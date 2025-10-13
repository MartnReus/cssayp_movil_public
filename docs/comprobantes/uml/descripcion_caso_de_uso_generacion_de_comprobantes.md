# Descripción diagrama Caso de Uso - Módulo de Generación de Comprobantes Digitales

**Actores principales**
* Afiliado: afiliado activo en la Caja que interactúa directamente con la app móvil para pagar, consultar o descargar comprobantes.

**Actores secundarios**
* Sistema de la Caja: sistema que valida pagos y genera comprobantes oficiales.
* Pasarela de pago: sistema que confirma el estado del pago en línea.

**Descripción Casos de Uso**

|                     **Caso de Uso**                       |                     **Descripción**                                        |
|:------------------------------------------------------|:--------------------------------------------------------------------------|
|Generar comprobante digital                            |El sistema genera automáticamente el comprobante digital tras confirmar el pago|
|Consultar comprobante desde historial                  |El afiliado accede a una boleta pagada desde su historial para ver el comprobante|
|Visualizar comprobante digital                         |El sistema muestra los datos esenciales del comprobante (número, fecha, monto, etc.)|
|Descargar comprobante PDF                              |El afiliado descarga el comprobante en formato PDF oficial desde la app|

# Casos de Uso principales y flujos
### Caso de uso: Generar comprobante digital (flujo automático)
**Descripción:**  
El sistema genera automáticamente el comprobante digital tras la confirmación exitosa del pago de una boleta.

**Flujo principal:**  
1. El afiliado realiza el pago de una boleta (módulo anterior).  
2. La pasarela de pago envía la confirmación del pago al sistema de la Caja.  
3. El sistema genera automáticamente el comprobante digital con la información requerida.  
4. El comprobante se almacena localmente en la app del usuario.  

**Precondiciones:**  
- El pago de la boleta debe haber sido confirmado exitosamente.  
- El afiliado debe estar autenticado en la aplicación.

**Postcondiciones:**  
- El comprobante digital queda disponible en el historial del afiliado.  

**Relaciones:**  
- «include» con *Confirmar pago* (del módulo de pago).

---

### Caso de uso: Consultar comprobante desde historial
**Descripción:**  
El afiliado accede a una boleta pagada desde su historial para consultar el comprobante digital correspondiente.

**Flujo principal:**  
1. El afiliado accede a la sección de historial de boletas.  
2. Selecciona una boleta marcada como "paga".  
3. El caso de uso continúa con *Visualizar comprobante digital*.  

**Precondiciones:**  
- El afiliado debe tener boletas pagas en su historial.  
- El afiliado debe estar autenticado en la aplicación.

**Postcondiciones:**  
- El afiliado puede visualizar los datos del comprobante.  

**Relaciones:**  
- «include» con *Visualizar comprobante digital*.

---

### Caso de uso: Visualizar comprobante digital (include de Consultar comprobante desde historial)
**Descripción:**  
El sistema muestra los datos esenciales del comprobante digital en pantalla.

**Flujo principal:**  
1. El sistema recupera los datos del comprobante desde el almacenamiento local.  
2. Se muestran los datos esenciales del comprobante (número de boleta, fecha, monto, forma de pago, etc.).  
3. El afiliado puede visualizar toda la información del comprobante.  

**Flujo alternativo:**  
- **A1:** Si el comprobante no está disponible localmente, el sistema solicita al Sistema de la Caja la información del comprobante.

---

### Caso de uso: Descargar comprobante PDF (extend de Consultar comprobante desde historial)
**Descripción:**  
El afiliado descarga el comprobante en formato PDF oficial conforme a las normas institucionales.

**Flujo principal:**  
1. Desde la pantalla de visualización, el afiliado selecciona "Descargar comprobante".  
2. La app solicita al sistema de la Caja la generación del PDF oficial, conforme a las normas institucionales.  
3. El sistema genera el PDF con el formato oficial requerido.  
4. El comprobante se descarga y almacena en el dispositivo móvil.  

**Precondiciones:**  
- El comprobante debe estar disponible y visualizado previamente.  
- El dispositivo debe tener espacio suficiente para almacenar el archivo PDF.

**Postcondiciones:**  
- El comprobante PDF queda disponible en el dispositivo del afiliado.  

**Flujo alternativo:**  
- **A1:** Si no hay conexión a internet, el sistema informa que la descarga no está disponible en este momento.  
- **A2:** Si el sistema de la Caja no puede generar el PDF, se muestra un mensaje de error y se permite reintentar.

**Relaciones:**  
- «include» con *Visualizar comprobante digital*.  
- «extend» desde *Consultar comprobante desde historial*.

![Diagrama](/docs/comprobantes/uml/CU_Modulo_de_generacion_de_comprobantes.png)  
