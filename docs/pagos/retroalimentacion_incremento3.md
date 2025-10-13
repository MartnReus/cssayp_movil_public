# Retroalimentación - Incremento 3: Módulo de Pago de Boletas

**Fecha:** 03/10/2025

**Participantes:** Martín Reus, Juan José Mendez (Jefe del área de Sistemas)

**Módulo revisado:** Módulo de pago de boletas mediante pasarelas de pago.

## Comentarios Generales

El funcionamiento del módulo fue considerado correcto y sin mayores observaciones.

## Retroalimentación sobre Criterios de Aceptación

* **Criterio:** Las boletas pendientes pueden ser pagadas mediante tarjeta (PayWay) o home banking (Red Link).
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** Al verificarse y completarse el pago, el estado de la boleta se actualiza en la aplicación y en el sistema de la Caja.
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** En caso de error en la transacción, se informa al usuario de forma clara y se ofrece reintento.
  * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** Los pagos realizados quedan registrados en el historial del usuario.
  * **Comentarios:** El funcionamiento es correcto.

## Sugerencias y Requerimientos Adicionales

* **Pago de boletas creadas anteriormente:**
  * Continuar investigando cómo implementar el pago a través del link de pago de Red Link para boletas creadas anteriormente. Actualmente solo se pueden pagar Boletas de Inicio durante su creación; se debe explorar la posibilidad de permitir el pago de boletas ya creadas en otro momento.
* **Visualización de datos del comprobante:**
  * Basarse en la información del comprobante que se obtiene actualmente en otros sistemas de la Caja para generar el comprobante en la aplicación.
  * Mostrar los datos del comprobante en una pantalla de la aplicación y dar la opción de descargarlo en formato digital.
* **Modificación de la barra de navegación principal:**
  * La barra de navegación principal debe contener los botones "Inicio", "Vida Activa", "Boletas" y "Más".
  * Esto reemplazaría el layout actual que contiene los botones "Inicio", "Boletas", "Pagos" y "Más".
  * Mover el botón de "Pagos" dentro de la sección "Más".

## Acciones a seguir

* Investigar e implementar la funcionalidad de pago mediante Red Link para boletas creadas con anterioridad.
* Diseñar e implementar una pantalla de visualización de datos del comprobante de pago basándose en los comprobantes actuales del sistema de la Caja.
* Incorporar la opción de descarga del comprobante digital desde la aplicación.
* Rediseñar la barra de navegación principal eliminando el botón "Pagos" de la navegación principal y moviéndolo a la sección "Más", agregando el botón "Vida Activa" en su lugar.
* Incluir un mensaje en la pantalla de recuperación de contraseña para que los usuarios puedan contactar a Mesa de Entradas. Incluir los medios de contacto (correo electrónico y teléfono).