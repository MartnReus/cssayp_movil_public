# Listado Priorizado de Cambios - Incremento 3: Módulo de Pago de Boletas

**Fecha:** 06/10/2025

**Basado en:** Retroalimentación del 03/10/2025

## Descripción

A partir de la retroalimentación obtenida de la presentación de la funcionalidad del módulo de pago de boletas al Jefe del área de Sistemas, se han identificado las siguientes mejoras y funcionalidades adicionales para implementar.
La retroalimentación obtenida que hace referencia a funcionalidades del módulo de generación de comprobantes se tendrá en cuenta para su implementación durante el incremento 4, pero no será considerada como un "cambio" a implementar ya que este módulo aún no existe.

## Cambios Identificados

### 1. Mejoras en Funcionalidades de Pago

#### 1.1 Pago de Boletas Creadas Anteriormente mediante Red Link

**Descripción:** Implementar la funcionalidad para permitir el pago a través del link de pago de Red Link para boletas creadas con anterioridad.
Actualmente solo se pueden pagar Boletas de Inicio durante su creación.

**Fuente:** Requerimiento del Jefe de Sistemas

**Prioridad:** P1

**Acción a Tomar:**
Continuar investigando la implementación técnica del pago mediante Red Link para boletas ya existentes.
Desarrollar e implementar esta funcionalidad en el próximo incremento disponible.

**Justificación:**
Esta funcionalidad es esencial para simplificar el flujo de pago de los afiliados, permitiéndoles pagar boletas generadas previamente y no solo al momento de su creación.

---

### 2. Mejoras de Navegación y Experiencia de Usuario

#### 2.1 Rediseño de la Barra de Navegación Principal

**Descripción:** Modificar la barra de navegación principal para contener los botones "Inicio", "Vida Activa", "Boletas" y "Más", reemplazando el layout actual que contiene "Inicio", "Boletas", "Pagos" y "Más". El botón "Pagos" debe moverse a la sección "Más".

**Fuente:** Requerimiento del Jefe de Sistemas

**Prioridad:** P2

**Acción a Tomar:**
Rediseñar la estructura de navegación principal de la aplicación. Agregar el botón "Vida Activa" y reubicar el botón "Pagos" dentro del menú "Más".

**Justificación:**
Esta reorganización mejora la jerarquía de navegación, dando prioridad a las funcionalidades más utilizadas y preparando la aplicación para la incorporación de la pantalla de información sobre "Vida Activa".

## Escala de Prioridad Utilizada

- **P1 (Alta)** - Crítico, implementar en el próximo incremento
- **P2 (Media)** - Importante, implementar en incrementos cercanos  
- **P3 (Baja)** - Deseable, implementar cuando haya capacidad disponible
