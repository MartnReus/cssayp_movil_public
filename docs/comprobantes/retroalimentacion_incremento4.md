# Retroalimentación - Incremento 4: Módulo de Generación de Comprobantes Digitales

**Fecha:** 03/11/2025

**Participantes:** Martín Reus, Juan José Mendez (Jefe del área de Sistemas)

**Módulo revisado:** Módulo de generación de comprobantes digitales para boletas pagadas.

## Comentarios Generales

El funcionamiento del módulo fue considerado correcto y sin mayores observaciones.

## Retroalimentación sobre Criterios de Aceptación

* **Criterio:** Al completarse el pago de una boleta, se genera un comprobante en formato PDF.
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** El comprobante en formato digital incorpora la misma información obligatoria presente en el comprobante físico.
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** El comprobante se almacena localmente en el dispositivo y puede visualizarse sin conexión.
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** El usuario puede compartir o descargar el comprobante desde la aplicación.
  * **Comentarios:** El funcionamiento es correcto.

## Sugerencias y Requerimientos Adicionales

* **Información adicional para pagos con tarjeta:**
  * Cuando el método de pago utilizado sea con tarjeta, el comprobante debe mostrar información más detallada sobre la transacción, incluyendo:
    * Tipo de tarjeta (crédito o débito)
    * Cantidad de cuotas
    * Banco emisor de la tarjeta
* **Código QR de validación:**
  * Incorporar un código QR en el comprobante digital que permita la validación del pago por parte de terceros.
  * El código QR debe dirigir a una página web de la Caja (ya existente) que muestre el estado de la boleta y confirme que ha sido pagada.
  * Esto facilitará la verificación de la validez del comprobante por parte del Poder Judicial u otras instituciones que lo requieran.

## Acciones a seguir

* Modificar la generación del comprobante para incluir información detallada de la transacción cuando el método de pago sea con tarjeta (tipo de tarjeta, cantidad de cuotas y banco emisor).
* Implementar la generación de un código QR en el comprobante digital que vincule con la página de validación de boletas de la Caja.
* Verificar la integración con la página de validación existente de la Caja para garantizar que el código QR funcione correctamente.