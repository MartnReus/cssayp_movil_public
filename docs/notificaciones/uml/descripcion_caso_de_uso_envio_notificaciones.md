# Descripción diagrama Caso de Uso - Módulo de Envío de Notificaciones

**Actores principales**
* Sistema de la Caja: backend institucional que analiza el historial de aportes y coordina el envío de notificaciones automáticas.

**Actores secundarios**
* Firebase Cloud Messaging (FCM): servicio externo que entrega notificaciones push a los dispositivos móviles.
* Servidor de Correo Electrónico: servicio que envía los correos electrónicos a los afiliados con email registrado.
* Afiliado: receptor pasivo de las notificaciones push y correos electrónicos.

**Descripción Casos de Uso**

|                     **Caso de Uso**                       |                     **Descripción**                                        |
|:----------------------------------------------------------|:---------------------------------------------------------------------------|
|Analizar historial de aportes                              |El sistema revisa los registros de aportes para determinar eventos relevantes|
|Detectar boletas por vencer                                |Identifica boletas con vencimiento próximo para disparar alertas preventivas|
|Detectar boletas pendientes de pago                        |Detecta boletas emitidas pero no abonadas para recordar el pago pendiente|
|Detectar falta de aportes mínimos                          |Evalúa si el afiliado no alcanza el aporte mínimo mensual y genera aviso|
|Detectar boletas pagadas e imputadas                       |Confirma que las boletas pagadas fueron imputadas y notifica al afiliado|
|Generar mensaje de notificación                            |Construye el mensaje con contenido, tipo y canal adecuados|
|Enviar notificación push                                   |Remite la notificación push mediante FCM a la app móvil del afiliado|
|Enviar correo electrónico                                  |Envía el correo electrónico con el recordatorio correspondiente|

# Casos de Uso principales y flujos
### Caso de uso: Analizar historial de aportes (flujo automático)
**Descripción:**  
El sistema revisa periódicamente el historial de aportes de cada afiliado para identificar comportamientos y eventos relevantes.

**Flujo principal:**  
1. El sistema solicita los aportes registrados del afiliado.  
2. Procesa la información histórica para identificar patrones y frecuencia de aportes.  
3. Determina qué procesos de detección deben ejecutarse según la información disponible.  
4. Continúa con los casos de uso de detección correspondientes.  

**Precondiciones:**  
- El afiliado debe contar con historial de aportes registrado.  
- El sistema debe poder acceder a la información histórica del afiliado.  

**Postcondiciones:**  
- Se identifican los eventos que requieren notificación y se activan los casos de detección.  

**Relaciones:**  
- «include» con *Detectar boletas por vencer*.  
- «include» con *Detectar boletas pendientes de pago*.  
- «include» con *Detectar falta de aportes mínimos*.  
- «include» con *Detectar boletas pagadas e imputadas*.  

---

### Caso de uso: Detectar boletas por vencer (include de Analizar historial de aportes)
**Descripción:**  
Identifica las boletas cuyo vencimiento ocurrirá dentro de los próximos 1 o 2 días para generar alertas preventivas.

**Flujo principal:**  
1. El sistema filtra las boletas del afiliado por fecha de vencimiento.  
2. Selecciona las boletas con vencimiento próximo (1 o 2 días).  
3. Marca los casos que requieren envío de notificación preventiva.  
4. Registra la necesidad de notificación para la boleta correspondiente.  

**Precondiciones:**  
- Deben existir boletas con fecha de vencimiento registrada.  

**Postcondiciones:**  
- Las boletas próximas a vencer quedan listas para el envío de notificaciones.  

**Relaciones:**  
- «include» con *Generar mensaje de notificación*.  

---

### Caso de uso: Detectar boletas pendientes de pago (include de Analizar historial de aportes)
**Descripción:**  
Detecta boletas generadas pero no abonadas para recordar al afiliado el pago antes del vencimiento.

**Flujo principal:**  
1. El sistema revisa las boletas emitidas y verifica su estado de pago.  
2. Identifica las boletas pendientes con proximidad a la fecha de vencimiento.  
3. Registra la necesidad de enviar una notificación recordatoria.  

**Precondiciones:**  
- Deben existir boletas emitidas cuya fecha de vencimiento no haya expirado.  

**Postcondiciones:**  
- Las boletas pendientes de pago quedan asociadas a un evento de notificación.  

**Relaciones:**  
- «include» con *Generar mensaje de notificación*.  

---

### Caso de uso: Detectar falta de aportes mínimos (include de Analizar historial de aportes)
**Descripción:**  
Comprueba si el afiliado no alcanza el aporte mínimo mensual y genera el recordatorio correspondiente.

**Flujo principal:**  
1. El sistema calcula el total de aportes del período vigente.  
2. Compara los aportes efectuados con el mínimo requerido.  
3. Determina si es necesario emitir un aviso para regularizar la situación.  
4. Registra el evento para la generación de notificación.  

**Precondiciones:**  
- Deben existir reglas institucionales para definir el aporte mínimo mensual.  

**Postcondiciones:**  
- Se habilita el envío de un recordatorio de regularización al afiliado.  

**Relaciones:**  
- «include» con *Generar mensaje de notificación*.  

---

### Caso de uso: Detectar boletas pagadas e imputadas (include de Analizar historial de aportes)
**Descripción:**  
Confirma que los pagos realizados fueron imputados y notifica al afiliado para confirmar la acreditación.

**Flujo principal:**  
1. El sistema verifica el estado de imputación de las boletas pagadas.  
2. Identifica las boletas cuya imputación fue confirmada.  
3. Registra el evento para enviar una notificación de confirmación.  

**Precondiciones:**  
- El sistema debe recibir la confirmación de imputación desde los procesos de pago.  

**Postcondiciones:**  
- Las boletas imputadas quedan marcadas para enviar la notificación de confirmación.  

**Relaciones:**  
- «include» con *Generar mensaje de notificación*.  

---

### Caso de uso: Generar mensaje de notificación
**Descripción:**  
Construye el mensaje a enviar al afiliado, definiendo el contenido, tipo y canal apropiados según el evento detectado.

**Flujo principal:**  
1. El sistema recibe los eventos de detección que requieren notificación.  
2. Determina el tipo de mensaje (preventivo, recordatorio, confirmación).  
3. Selecciona el canal de envío disponible para el afiliado (push o correo).  
4. Ensambla el contenido del mensaje con la información relevante.  
5. Continúa con el caso de uso de envío correspondiente.  

**Precondiciones:**  
- Debe existir al menos un evento de detección registrado.  
- El afiliado debe tener configurado al menos un canal de contacto válido.  

**Postcondiciones:**  
- El mensaje queda listo para ser enviado por el canal seleccionado.  

**Relaciones:**  
- «include» con *Enviar notificación push*.  
- «include» con *Enviar correo electrónico*.  

---

### Caso de uso: Enviar notificación push (include de Generar mensaje de notificación)
**Descripción:**  
Entrega al afiliado el mensaje a través de una notificación push en la app móvil.

**Flujo principal:**  
1. El sistema prepara la carga del mensaje para FCM.  
2. Envía la solicitud a Firebase Cloud Messaging.  
3. FCM distribuye la notificación al dispositivo móvil del afiliado.  
4. El dispositivo recibe la notificación y la muestra al usuario.  

**Precondiciones:**  
- El afiliado debe tener la app instalada y asociada a un token válido de FCM.  
- Debe existir conectividad con el servicio FCM.  

**Postcondiciones:**  
- El afiliado recibe la notificación push en su dispositivo.  

**Relaciones:**  
- Actor secundario: Firebase Cloud Messaging (FCM).  

---

### Caso de uso: Enviar correo electrónico (include de Generar mensaje de notificación)
**Descripción:**  
Remite el recordatorio por correo electrónico al afiliado.

**Flujo principal:**  
1. El sistema valida que el afiliado tenga un correo electrónico registrado.  
2. Construye el mensaje en formato compatible con el servidor de correo.  
3. Envía la solicitud al Servidor de Correo Electrónico.  
4. El servidor despacha el correo al buzón del afiliado.  

**Precondiciones:**  
- El afiliado debe tener una dirección de correo válida registrada.  
- Debe existir conectividad con el servidor de correo.  

**Postcondiciones:**  
- El afiliado recibe el correo electrónico con el recordatorio o confirmación.  

**Relaciones:**  
- Actor secundario: Servidor de Correo Electrónico.  

---

![Diagrama](/docs/notificaciones/uml/CU_Modulo_de_envio_de_notificaciones.png)  


