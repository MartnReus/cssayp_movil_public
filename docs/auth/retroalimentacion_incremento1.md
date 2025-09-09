# Retroalimentación - Incremento 1: Módulo de Inicio de Sesión
**Fecha:** 07/08/2025

**Participantes:** Martín Reus, Juan José Mendez (Jefe del área de Sistemas)

**Módulo revisado:** Módulo de inicio de sesión y autenticación biométrica.

## Comentarios Generales
El funcionamiento del módulo fue considerado correcto y sin mayores observaciones.

## Retroalimentación sobre Criterios de Aceptación
* **Criterio:** El usuario puede iniciar sesión correctamente con las credenciales del sistema CGA.
    * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** Si las credenciales son inválidas, se muestra un mensaje de error claro.
    * **Comentarios:** El funcionamiento es correcto.
* **Criterio:** En dispositivos compatibles, se permite el acceso mediante huella digital o reconocimiento facial.
    * **Comentarios:** El funcionamiento es correcto.

## Sugerencias y Requerimientos Adicionales
* **Recuperación de contraseña:**
    * Permitir el uso de un solo identificador (NAF o DNI) en lugar de ambos para la recuperación de contraseña. Se sugiere que el usuario pueda ingresar cualquiera de los dos.
    * Si el correo electrónico ingresado para la recuperación es incorrecto, se debe mostrar un mensaje que sugiera el correo registrado de forma parcial (ejemplo: `j******z@h***.com.ar`).
    * Añadir un mensaje en la pantalla de recuperación de contraseña que indique al usuario que puede ponerse en contacto con el Mesa de Entradas de la Caja por correo electrónico o por teléfono en caso de problemas en el reestablecimiento de la contraseña.

## Acciones a seguir
* Ajustar la lógica de la pantalla de recuperación de contraseña para aceptar el NAF o el DNI como único campo de validación.
* Modificar la pantalla de recuperación de contraseña para mostrar un mensaje parcial del correo electrónico en caso de error.
* Incluir un mensaje en la pantalla de recuperación de contraseña para que los usuarios puedan contactar a Mesa de Entradas. Incluir los medios de contacto (correo electrónico y teléfono).