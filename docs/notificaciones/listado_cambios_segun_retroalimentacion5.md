# Listado Priorizado de Cambios - Incremento 5: Módulo de Envío de Notificaciones

**Fecha:** 27/11/2025

**Basado en:** Retroalimentación del 27/11/2025

## Descripción

A partir de la retroalimentación obtenida de la presentación de la funcionalidad del módulo de envío de notificaciones push y sistema inteligente de recordatorios al Jefe del área de Sistemas, se han identificado las siguientes mejoras y funcionalidades adicionales para evaluar.

## Cambios Identificados

### 1. Mejoras de Visualización y Rendimiento

#### 1.1 Paginación o Carga Incremental de Notificaciones

**Descripción:** Implementar un sistema de paginación o carga incremental (scroll infinito) en el listado de notificaciones para optimizar el rendimiento cuando el número de notificaciones acumuladas sea significativo.

**Fuente:** Sugerencia del Jefe del área de Sistemas

**Prioridad:** P3

**Acción a Tomar:**
Evaluar la necesidad de implementación según el crecimiento del volumen de notificaciones. Monitorear el rendimiento del listado actual y, de ser necesario, implementar paginación en el backend y carga incremental en la aplicación móvil.

**Justificación:**
Actualmente el volumen de notificaciones no justifica la implementación inmediata de esta mejora. El sistema funciona correctamente con el listado completo. Esta optimización sería relevante solo si el número de notificaciones por usuario crece significativamente a largo plazo, lo cual debería monitorearse durante el uso real de la aplicación.

---

## Cambios No Identificados

Es importante destacar que durante la revisión del módulo no se identificaron cambios obligatorios ni mejoras críticas, todos los criterios de aceptación fueron evaluados positivamente.

## Escala de Prioridad Utilizada

- **P1 (Alta)** - Crítico, implementar en el próximo incremento
- **P2 (Media)** - Importante, implementar en incrementos cercanos  
- **P3 (Baja)** - Deseable, implementar cuando haya capacidad disponible
