# Definición lógica de análisis y envío de notificaciones

## 1. Objetivo del módulo
El objetivo del módulo de **análisis y envío de notificaciones** es automatizar el proceso de comunicación con los afiliados, recordándoles sus obligaciones de pago, vencimientos y movimientos de boletas.  
Este sistema busca optimizar la regularidad de los aportes mediante recordatorios inteligentes, adaptados al comportamiento de cada usuario.

---

## 2. Descripción general del proceso
El módulo se ejecuta de forma programada (por ejemplo, una vez al día) y realiza un **análisis del historial de aportes de cada afiliado**.  
A partir de esta información, determina:

- El **estado actual de sus boletas** (pendientes, próximas a vencer, pagadas, etc.).
- El **nivel de cumplimiento** respecto a los aportes mínimos requeridos.
- La **frecuencia personalizada** con la que se deben enviar recordatorios.

Una vez identificada una condición que amerita una notificación, el sistema genera el mensaje correspondiente y lo envía por los canales disponibles: **notificación push** y/o **correo electrónico**.

---

## 3. Entradas del sistema

| Dato | Descripción |
|------|--------------|
| Historial de boletas | Información sobre boletas generadas, vencidas, pagadas e imputadas. |
| Fecha actual | Referencia temporal para calcular vencimientos. |
| Datos del afiliado | Nombre, número de afiliado, correo electrónico, token de dispositivo móvil. |
| Reglas de frecuencia | Parámetros definidos por el sistema (por ejemplo, analizar diariamente, enviar recordatorios cada cierto número de días, etc.). |

---

## 4. Lógica de análisis

El sistema evalúa secuencialmente las siguientes condiciones para determinar qué tipo de notificación corresponde enviar:

### 4.1. Boletas por vencer
- **Condición:** existen boletas con vencimiento dentro de 1 o 2 días.  
- **Acción:** generar recordatorio con asunto “Boleta próxima a vencer”.  
- **Canal:** notificación push + correo electrónico.

### 4.2. Boletas pendientes de pago
- **Condición:** hay boletas generadas que aún no fueron abonadas, y cuyo vencimiento todavía no llegó.  
- **Acción:** generar recordatorio de pago anticipado.  
- **Canal:** notificación push.

### 4.3. Aportes mínimos no cubiertos
- **Condición:** no existen boletas pendientes, pero el afiliado no alcanza el aporte mínimo correspondiente a la categoría básica.  
- **Acción:** enviar recordatorio general para realizar nuevos aportes.  
- **Canal:** notificación push.

### 4.4. Boletas pagadas e imputadas
- **Condición:** se detectan boletas cuyo pago fue acreditado e imputado correctamente (por ejemplo, al siguiente día hábil).  
- **Acción:** enviar mensaje de confirmación al afiliado.  
- **Canal:** notificación push.

---

## 5. Frecuencia de análisis
El proceso se ejecuta automáticamente mediante un **servicio programado (scheduler)**:

- Ejecución **diaria**, preferentemente en horario nocturno o fuera del horario laboral.
- Se analiza el conjunto de afiliados activos.
- Se registran en base de datos los envíos realizados para evitar duplicaciones.

---

## 6. Generación y envío de notificaciones
Una vez determinada la necesidad de notificar, el sistema:

1. Construye el mensaje con base en una **plantilla predefinida** según el tipo de evento.
2. Registra el envío en una tabla de control (`notificaciones_enviadas`).
3. Envía el mensaje a través de los canales disponibles:
   - **Push:** mediante el servicio **Firebase Cloud Messaging (FCM)**.
   - **Correo:** mediante el **servidor SMTP institucional** o un servicio externo (por ejemplo, SendGrid).

---

## 7. Estructura lógica resumida (pseudocódigo)

```pseudocode
Para cada afiliado activo:
    obtener historial_boletas(afiliado)
    si existe boleta con vencimiento en 1 o 2 días:
        generar_notificacion("Boleta próxima a vencer")
        enviar(push, correo)
    si existe boleta pendiente de pago:
        generar_notificacion("Boleta pendiente")
        enviar(push)
    si no existen boletas pendientes y aportes < mínimo:
        generar_notificacion("Recordatorio de aportes mínimos")
        enviar(correo)
    si existe boleta recientemente imputada:
        generar_notificacion("Pago confirmado")
        enviar(push)
Registrar en base de datos los envíos realizados
```

---

## 8. Reglas de Negocio

1. El sistema debe analizar el historial de aportes de cada afiliado para determinar la frecuencia de envío de notificaciones, considerando comportamientos previos de pago (puntualidad, atrasos, frecuencia de aportes, etc.).  
2. No se deben enviar notificaciones duplicadas o reiteradas en un intervalo corto de tiempo (configurable).  
3. Las notificaciones deben enviarse únicamente a usuarios con datos de contacto válidos (token de dispositivo y/o correo electrónico registrado).  
4. Si el afiliado no posee boletas pendientes ni aportes recientes, se debe enviar un recordatorio general de aporte mínimo obligatorio.  
5. Todas las notificaciones enviadas deben registrarse en el sistema para fines de auditoría y trazabilidad.  
6. En caso de errores en el envío (fallo de red, token inválido, etc.), el sistema debe reintentar automáticamente según las políticas de reintento configuradas.

---

## 9. Excepciones y Manejo de Errores

| Escenario | Descripción | Acción del Sistema |
|------------|--------------|--------------------|
| **Usuario sin boletas activas** | El usuario no tiene boletas generadas. | Enviar recordatorio de aporte mínimo si corresponde. |
| **Token de notificación inválido o expirado** | El dispositivo móvil no puede recibir notificaciones. | Registrar el error y marcar el token como inválido. Se intentará reenviar por correo si hay uno disponible. |
| **Correo electrónico no registrado** | El usuario no tiene un correo en el sistema. | Enviar solo notificación push. Registrar advertencia. |
| **Fallo en servicio de notificaciones (p. ej., Firebase)** | Interrupción temporal del servicio externo. | Reintentar según política de reintentos (máx. 3 veces). Si persiste, registrar incidencia. |
| **Historial de aportes incompleto o inaccesible** | El sistema no puede acceder al historial del afiliado. | Postergar análisis hasta próximo ciclo y registrar evento. |

---

## 10. Seguridad y Privacidad

- Todas las comunicaciones con el servicio de notificaciones (p. ej., Firebase Cloud Messaging) deben realizarse mediante canales seguros (HTTPS).  
- Los tokens de dispositivos y direcciones de correo electrónico deben almacenarse cifrados en la base de datos.  
- Los datos personales de los afiliados no deben incluirse en el contenido de las notificaciones.  
- Se debe garantizar la conformidad con la normativa vigente en materia de protección de datos personales.  
- El acceso al módulo de análisis y envío de notificaciones estará restringido a procesos internos del sistema (sin intervención del usuario).  
- Se implementará un registro de auditoría para cada notificación enviada, incluyendo fecha, tipo de notificación, destino y resultado del envío.
