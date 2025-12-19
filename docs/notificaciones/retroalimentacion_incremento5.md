# Retroalimentación - Incremento 5: Módulo de Envío de Notificaciones

**Fecha:** 27/11/2025

**Participantes:** Martín Reus, Juan José Mendez (Jefe del área de Sistemas)

**Módulo revisado:** Módulo de envío de notificaciones push y sistema inteligente de recordatorios.

## Comentarios Generales

El funcionamiento del módulo fue considerado correcto y cumple satisfactoriamente con los objetivos planteados. El sistema de notificaciones push se integró correctamente con Firebase Cloud Messaging y el análisis del historial de aportes para determinar la frecuencia de envío funciona según lo esperado.

## Retroalimentación sobre Criterios de Aceptación

* **Criterio:** El sistema analiza el historial de aportes del usuario para determinar la frecuencia de notificaciones.
  * **Comentarios:** El funcionamiento es correcto. La lógica implementada en el backend analiza adecuadamente el comportamiento de pago de cada afiliado.

* **Criterio:** Se envían notificaciones push sobre vencimientos próximos, pagos atrasados o boletas pendientes.
  * **Comentarios:** El funcionamiento es correcto. Las notificaciones se reciben correctamente tanto en primer plano como en segundo plano.

* **Criterio:** También se envían recordatorios por correo electrónico (si el usuario tiene uno registrado).
  * **Comentarios:** El funcionamiento es correcto. El sistema de envío de correos electrónicos está operativo y funciona en conjunto con las notificaciones push.

## Sugerencias y Requerimientos Adicionales

* **Optimización de la visualización:**
  * Considerar agregar paginación o carga incremental si el número de notificaciones crece significativamente con el tiempo.

## Acciones a seguir

* Evaluar e implementar un sistema de paginación para el listado de notificaciones si se considera necesario.

## Conclusión

El módulo de notificaciones cumple exitosamente con su objetivo principal de mantener informados a los afiliados sobre sus obligaciones de pago y el estado de sus boletas. La implementación técnica es sólida y la integración con Firebase es correcta. La mejora sugerida no afecta la funcionalidad core del módulo a corto plazo, por lo que es necesario evaluar la necesidad de su implementación.