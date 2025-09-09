# Endpoints que utiliza el Sistema CGA para realizar la autenticación de usuarios
Este documento tiene como objetivo detallar que endpoints son utilizados en la funcionalidad de iniciar sesión en el Sistema CGA. 
Para determinar cuáles son los endpoints utilizados, se inspeccionaron las peticiones que se realizan al intentar iniciar sesión y recuperar la contraseña.
Los detalles acerca del funcionamiento de cada uno fueron obtenidos analizando el código de cada endpoint.

## Inicio de sesión

### Flujo de autenticación detallado
1. **Envío de credenciales (frontend)**: el afiliado ingresa su usuario y contraseña en la página web. 
El frontend envía una solicitud POST al endpoint de autenticación (https://cga.capsantafe.org.ar/cga/ws/usr/login)

2. **Llamada a la base de datos (backend)**: el endpoint del backend recibe el usuario y la contraseña.
No procesa la lógica de negocio internamente, sino que invoca la a función de la base de datos `lib_seguridad.Get_Nro_afiliado` pasándole las credenciales del usuario.

3. **Respuesta de la base de datos**:
    - Credenciales correctas: la función devuelve los datos del afiliado.
    - Credenciales incorrectas: la función devuelve el número de afiliado en 0 y un mensaje de "Datos incorrectos".

4. **Generación y envío de JWT (backend)**: Si las credeciales fueron correctas, se genera en el backend un JSON Web Token (JWT).
El backend devuelve la respuesta de la función de la base de datos y el token generado.

5. **Comportamiento del frontend**:
    - Credencialesa correctas: el frontend almacena el JWT en almacenamiento de sesión para ser incluido como `Authorization Header` en todas las peticiones subsiguientes hacia el backend.
    El usuario es redirigido a la pantalla principal.

    - Credenciales incorrectas: el frontend muestra el mensaje de error "Datos incorrectos" al afiliado.

### Campos de una petición de inicio de sesión

| Nombre del campo | Tipo de Dato | Requerido | Descripción |
| :--------------- | :----------- | :-------- | :---------- |
| `usuario`        | `string`     | Sí        | Nombre de usuario el sistema |
| `password`       | `string`     | Sí        | Contraseña el usuario |

### ✅ Campos de una respuesta correcta (credenciales válidas y correctas)
**Código de estado: 200**

| Nombre del campo   | Tipo de Dato | Descripción |
| :----------------- | :----------- | :---------- |
| `nro_afiliado`     | `int`        | Número identificador del afiliado |
| `apellido_nombres` | `string`     | Cadena de texto con el apellido y nombre del afiliado. Formato: *APELLIDO, NOMBRES* |
| `nombres`          | `string`     | Cadena de texto vacía. Legacy. **No utilizada**|
| `cambiar_password` | `int`        | Entero con valor 0 o 1, utilizado para determinar si el afiliado podrá cambiar la contraseña al ingresar |
| `token`            | `string`     | JSON Web Token que se utiliza en el header Authorization de cada petición posterior realizada como verificación de que el usuario está logueado |


### ❌ Campos de una respuesta incorrecta (credenciales incorrectas) 
**Código de estado: 200**

| Nombre del campo   | Tipo de Dato | Descripción |
| :----------------- | :----------- | :---------- |
| `nro_afiliado`     | `int`        | Valor fijo en `0` |
| `mensaje`          | `string`     | Cadena de texto con la descripción del error |

### ❌ Campos de una respuesta incorrecta (credenciales inválidas) 
**Código de estado: 500**

La respuesta contiene el html de una vista haciendo referencia a que ocurrió un error.




## Recuperación de contraseña
El endpoint que se encarga de cambiar la contraseña de un usuario es llamado cuando el afiliado ingresa a la pantalla de recuperación de contraseña presionando el botón "¿Olvidó su contraseña?".
Una vez dentro, debe ingresar su numero de afiliado, su número de DNI y completar un captcha para continuar con el proceso.
Los datos ingresados son enviados al endpoint https://cga.capsantafe.org.ar/cga/ws/usr/recuperar-password, en el cual (en el caso en que el captcha es correcto) se genera una le envía al afiliado a su correo electrónico una URL.
La URL lo redirecciona a una página del CGA en la que puede establecer una nueva contraseña.

### Campos de una petición de reestablecimiento de contraseña

| Nombre del campo | Tipo de Dato | Requerido | Descripción |
| :--------------- | :----------- | :-------- | :---------- |
| `nroAfiliado`    | `int`        | Sí        | Número identificador del afiliado |
| `nroDocumento`   | `int`        | Sí        | Número de documento del afiliado |
| `captcha`        | `string`     | Sí        | Solución al captcha presentado en la página |

