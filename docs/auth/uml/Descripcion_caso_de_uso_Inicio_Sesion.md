# Descripción diagrama Caso de Uso - Módulo de inicio de sesión

**Actores principales**
* Afiliado: afiliado activo en la Caja con credenciales correspondientes.

**Actores secundarios**
* Sistema de la Caja: sistema que maneja la base de datos de la Caja.

**Descripción Casos de Uso**

|                     **Caso de Uso**                       |                     **Descripción**                                        |
|:------------------------------------------------------|:--------------------------------------------------------------------------|
|Iniciar sesión                                         |El afiliado abre la aplicacion para ingresar al sistema             |
|Iniciar sesión con credenciales                       |El afiliado ingresa usuario y contraseña CGA para autenticarse             |
|Autenticar con datos biométricos                      |En dispositivos compatibles, puede acceder a su cuenta con huella o rostro|
|Recuperar contraseña                                   |Opción para recuperar acceso si olvidó su contraseña                       |
|Ingresar datos de recuperación                        |Campo obligatorio (ID afiliado, DNI, mail) para confirmar identidad del afiliado|
|Establecer nueva contraseña                           |Campo de nueva contraseña y repeticion de la misma. El sistema actualiza la contraseña en la cuenta del afiliado|

# Casos de Uso principales y flujos
### Caso de uso: Iniciar sesión
**Descripción:**  
El afiliado abre la aplicación para acceder a los servicios disponibles.  

**Flujo principal:**  
1. El afiliado abre la aplicación.  
2. El sistema muestra la pantalla de inicio de sesión con opciones de autenticación.  
3. El caso de uso continúa con un mecanismo de autenticación (credenciales o biometría).  

**Precondiciones:**  
- El afiliado debe estar registrado en el sistema de la Caja.  

**Postcondiciones:**  
- El afiliado accede a su cuenta si la autenticación es exitosa.  

---

### Caso de uso: Iniciar sesión con credenciales (extends de Iniciar sesión)
**Descripción:**  
El afiliado ingresa su usuario y contraseña CGA para autenticarse.  

**Flujo principal:**  
1. El afiliado introduce usuario y contraseña.  
2. El sistema valida las credenciales contra la base de datos.  
3. Si son correctas, el afiliado accede a su cuenta.  

**Flujo alternativo:**  
- **A1:** Si las credenciales son incorrectas, el sistema muestra un mensaje de error y permite reintentar.  

---

### Caso de uso: Autenticar con datos biométricos (extends de Iniciar sesión)
**Descripción:**  
En dispositivos compatibles, el afiliado puede acceder mediante huella digital o reconocimiento facial.  

**Flujo principal:**  
1. El afiliado selecciona autenticación biométrica.  
2. El dispositivo valida la huella o rostro.  
3. El sistema confirma la identidad y permite el acceso.  

**Flujo alternativo:**  
- **A1:** Si falla la autenticación biométrica, el sistema permite redirigir a la autenticación por credenciales.  

---

### Caso de uso: Recuperar contraseña
**Descripción:**  
Permite al afiliado recuperar el acceso si olvidó su contraseña.  

**Flujo principal:**  
1. El afiliado selecciona la opción **“Recuperar contraseña”**.  
2. El caso de uso continúa con **Ingresar datos de recuperación**.  

---

### Caso de uso: Ingresar datos de recuperación (include de Recuperar contraseña)
**Descripción:**  
El afiliado debe confirmar su identidad ingresando datos obligatorios (ID afiliado y DNI/correo electrónico).  

**Flujo principal:**  
1. El sistema solicita ID de afiliado y DNI/correo electrónico.  
2. El afiliado completa los campos y confirma.  
3. El sistema valida la información con su base de datos.
4. El sistema envia un mensaje con una contraseña temporal a la direccion de correo electronico del afiliado.  

**Flujo alternativo:**  
- **A1:** Si los datos no coinciden, el sistema informa error y solicita corrección.  

---

### Caso de uso: Establecer nueva contraseña (include de Recuperar contraseña)
**Descripción:**  
Al iniciar sesion con la contraseña temporal, el afiliado establece una nueva contraseña que la reemplazara. El **Sistema de la Caja** actualiza la base de datos con la nueva información.  

**Flujo principal:**  
1. El sistema habilita los campos para ingresar y repetir la nueva contraseña.  
2. El afiliado introduce los datos y confirma.  
3. El sistema valida que las contraseñas coincidan.  
4. El Sistema de la Caja actualiza la contraseña en la base de datos del afiliado.  

**Flujo alternativo:**  
- **A1:** Si las contraseñas no coinciden, el sistema solicita reingreso.  

**Postcondiciones:**  
- El afiliado puede iniciar sesión con su nueva contraseña. 

![Diagrama](/docs/auth/uml/CU_Modulo_de_inicio_de_sesion.png)
