# Documentación de Requerimientos Técnicos de los Métodos de Pago

## 1. Introducción
El presente documento describe los requerimientos técnicos asociados al **módulo de pagos de boletas** de la aplicación de autogestión de afiliados.  
Su objetivo principal es establecer las bases técnicas necesarias para la correcta integración de los distintos métodos de pago, asegurando la trazabilidad, la seguridad y la sincronización con los sistemas internos de la Caja.

### Alcance del módulo de pagos
El módulo permite que los afiliados realicen el pago de sus boletas de inicio y fin de juicio de manera digital, a través de las opciones habilitadas en la aplicación. Este proceso incluye la generación de comprobantes y la actualización automática del estado de cada boleta en el sistema de la Caja.  

### Métodos de pago contemplados
Actualmente, la aplicación contempla los siguientes métodos:
- **Red Link**: utilizado exclusivamente para boletas de inicio, a través de la generación de referencias de pago y redirección al home banking del afiliado.
- **PayWay**: utilizado para boletas de fin, mediante la integración con tarjetas de crédito y débito.

### Relación con otros módulos del sistema
El módulo de pagos se vincula directamente con:
- **Módulo de Boletas**: dado que el proceso de pago puede iniciarse desde la generación de una boleta, desde el historial o desde el menú de pagos.
- **Módulo de Historial**: los pagos realizados quedan registrados y pueden ser consultados posteriormente.
- **Sistema de la Caja**: los resultados de las transacciones deben sincronizarse en forma automática, reflejando los aportes en tiempo real y asegurando la consistencia entre la aplicación y el sistema central.
---

## 2. Requerimientos Generales
Los siguientes requerimientos aplican a todos los métodos de pago implementados en la aplicación. Establecen lineamientos comunes en términos de seguridad, trazabilidad, experiencia de usuario y sincronización con el sistema de la Caja.

### Seguridad
Todos los procesos de pago deben realizarse bajo protocolos seguros de comunicación (**HTTPS/TLS**), evitando la exposición de información sensible.

### Autenticación y autorización
Solo los afiliados autenticados en la aplicación podrán acceder a la sección de pagos. Cada operación de pago deberá validarse contra la sesión activa del usuario y asociarse al número de afiliado correspondiente, evitando transacciones no autorizadas.

### Resiliencia
El sistema debe manejar de forma adecuada:
- **Reintentos** en caso de errores de comunicación o timeouts.
- **Estados intermedios** (pago en proceso, confirmación pendiente).
- **Mensajes claros al usuario** en caso de fallos, con posibilidad de reintentar la operación.

### Notificaciones y comprobantes
Al completarse una transacción, la aplicación debe:
1. **Actualizar el estado de la boleta** en la aplicación y en el sistema central de la Caja.  
2. **Generar un comprobante digital** accesible para el afiliado en su historial de pagos.  
3. Enviar, en caso de corresponder, una **notificación push o correo electrónico** confirmando la operación.

---

## 3. Red Link (Pago de boletas de inicio)

### 3.1 Tipo de integración
La integración con **Red Link** se realiza mediante la **generación de una referencia de pago** desde la aplicación, la cual permite que el afiliado abone su boleta a través de su home banking.  
El flujo contempla:
- Generación del identificador único de boleta y código de referencia.
- Redirección del afiliado a su banca online (Red Link).
- Espera de confirmación del pago desde Red Link hacia el sistema de la Caja.

### 3.2 Flujos soportados
- Pago único de boletas de inicio.  
- Posibilidad de iniciar el pago desde:
  - El menú de pagos.  
  - La pantalla de creación de boleta.  
  - El historial de boletas.  

### 3.3 Formatos de datos
La aplicación debe enviar a Red Link la siguiente información mínima:  
- **Identificador de boleta** (ID único en el sistema).  
- **Monto total** a abonar.  
- **Código de referencia de pago** generado dinámicamente.  

La confirmación recibida incluirá:  
- Estado de la transacción (aprobada, pendiente).  
- Identificador de la operación.  
- Marca temporal del pago.  

### 3.4 Restricciones
- Solo está disponible para boletas de inicio.  
- El procesamiento depende de la disponibilidad del servicio de Red Link.  
- La confirmación del pago puede no ser inmediata, debiendo contemplarse estados intermedios en la aplicación.  

---

## 4. PayWay (Pago con tarjeta de crédito/débito – boletas de fin)

### 4.1 Tipo de integración
La integración con **PayWay** se realiza a través de sus **APIs REST/SDK oficiales**, permitiendo el pago con tarjetas de crédito y débito.  
El flujo contempla:
- Generación de la orden de pago en la aplicación.
- Envío seguro de los datos de la tarjeta mediante tokenización.
- Confirmación en tiempo real de la transacción.
- Actualización inmediata del estado de la boleta en la aplicación y en el sistema de la Caja.

### 4.2 Flujos soportados
- Pago individual de boletas de fin desde:
  - El menú de pagos.  
  - La creación de una boleta.  
  - El historial de boletas.  
- Autorización y confirmación en línea de la transacción.
- Reintento de la operación en caso de fallo de comunicación.

### 4.3 Formatos de datos
Los datos principales a enviar incluyen:
- **Identificador de boleta** (ID único).  
- **Monto total** de la operación.  
- **Datos de tarjeta** (número, fecha de vencimiento, código de seguridad) transmitidos en forma encriptada o tokenizada.  

La confirmación de PayWay incluye:
- Estado de la transacción (aprobada, rechazada).  
- Identificador único de transacción de PayWay.  
- Fecha y hora de la operación.  

### 4.4 Restricciones
- Disponible únicamente para el pago de boletas de fin.  
- Requiere conexión estable para completar la operación en tiempo real.  
