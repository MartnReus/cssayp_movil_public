# Listado Priorizado de Cambios - Incremento 4: Módulo de Generación de Comprobantes Digitales

**Fecha:** 03/11/2025

**Basado en:** Retroalimentación del 03/11/2025

## Descripción

A partir de la retroalimentación obtenida de la presentación de la funcionalidad del módulo de generación de comprobantes digitales para boletas pagadas al Jefe del área de Sistemas, se han identificado las siguientes mejoras y funcionalidades adicionales para implementar.

## Cambios Identificados

### 1. Mejoras en Información del Comprobante

#### 1.1 Información Adicional para Pagos con Tarjeta

**Descripción:** Cuando el método de pago utilizado sea con tarjeta, el comprobante debe mostrar información más detallada sobre la transacción, incluyendo:
- Tipo de tarjeta (crédito o débito)
- Cantidad de cuotas
- Banco emisor de la tarjeta

**Fuente:** Sugerencia del Jefe del área de Sistemas

**Prioridad:** P2

**Acción a Tomar:**
Modificar la generación del comprobante para incluir información detallada de la transacción cuando el método de pago sea con tarjeta (tipo de tarjeta, cantidad de cuotas y banco emisor).

**Justificación:**
Esta mejora proporciona mayor transparencia y detalle en los comprobantes de pago con tarjeta, facilitando la verificación y el seguimiento de las transacciones realizadas por los afiliados.

---

### 2. Funcionalidades de Validación

#### 2.1 Código QR de Validación

**Descripción:** Incorporar un código QR en el comprobante digital que permita la validación del pago por parte de terceros. El código QR debe dirigir a una página web de la Caja (ya existente) que muestre el estado de la boleta y confirme que ha sido pagada. Esto facilitará la verificación de la validez del comprobante por parte del Poder Judicial u otras instituciones que lo requieran.

**Fuente:** Sugerencia del Jefe del área de Sistemas

**Prioridad:** P1

**Acción a Tomar:**
Implementar la generación de un código QR en el comprobante digital que vincule con la página de validación de boletas de la Caja. Verificar la integración con la página de validación existente de la Caja para garantizar que el código QR funcione correctamente.

**Justificación:**
Esta funcionalidad es esencial para permitir la validación del comprobante por parte de terceros, especialmente instituciones como el Poder Judicial, lo cual aumenta la confiabilidad y utilidad del comprobante digital generado.

## Escala de Prioridad Utilizada

- **P1 (Alta)** - Crítico, implementar en el próximo incremento
- **P2 (Media)** - Importante, implementar en incrementos cercanos  
- **P3 (Baja)** - Deseable, implementar cuando haya capacidad disponible

