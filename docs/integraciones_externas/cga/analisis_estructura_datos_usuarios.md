# Análisis de la estructura de datos de usuarios del Sistema de Consulta y Gestión de Afiliados (CGA)
Este documento tiene como objetivo detallar de la forma más específica posible la estructura de los usuarios del Sistema CGA para ser utilizado como base en el desarrollo del módulo de inicio de sesión del proyecto CSSAYP Móvil.

## Obtención de la información
Para realizar este documento fue analizada la base de datos de la Caja que contiene la tabla de usuarios. Para llevar a cabo este trabajo se utilizó la herramienta DataGrip, la cual permitió examinar la información específica de cada tabla. También permitió la generación de un Modelo de Datos Fisico que permite observar las relaciones entre las tablas.

## Estructura de Datos de Usuario del Sistema CGA
- Nombre de la tabla principal de usuarios: CD_USUARIO_CGA
- Esquema en el que se encuentra: CJ_CGA
- Descripción general: La tabla almacena el usuario y la contraseña del afiliado. Entre los principales datos adicionales que se almacenan se encuentra el número de afiliado.

## Campos almacenados en la tabla
Como fue mencionado anteriormente, la tabla principal de usuarios se denomina `CJ_CGA.CD_USUARIO_CGA`. A continuación, se detallan los campos que almacena:

| Nombre del Campo    | Tipo de Dato | Longitud/Formato | ¿Nulo? | Descripción |
| :------------------ | :----------- | :--------------- | :----- | :---------- |
| `NRO_AFILIADO`      | `NUMBER`     | -                | No     | Número de afiliado, clave primaria de la tabla. Representa el identificador único del usuario y del abogado en lo que respecta a la Caja. |
| `NOMBRE_USUARIO`    | `VARCHAR2`   | 20               | Sí     | Nombre de usuario o login para acceder al Sistema CGA. |
| `PWD`               | `VARCHAR2`   | 20               | Sí     | Contraseña del usuario en un formato legacy. **Nota: Este campo se mantiene en la tabla pero actualmente ya no es utilizado ni actualizado. El campo que se utiliza es `PWD_HEX`.** |
| `FECHA_MODIFICACION`| `DATE`       | -                | Sí     | Fecha de la última modificación de los datos del usuario o su contraseña. |
| `MATRICULA_OLD`     | `NUMBER`     | 6                | Sí     | Campo no utilizado de propósito desconocido. Valor `NULL` en todos los registros de la tabla. |
| `IS_DEFAULT_PWD`    | `NUMBER`     | 1                | Sí     | Indicador (0 o 1) que señala si la contraseña del usuario es la contraseña por defecto (valor predeterminado es 1). Se utiliza a la hora de crear el usuario o de reestablecer la contraseña. En esos casos el usuario ingresa al sistema con una contraseña brindada por la Caja y se le permite cambiarla por una propia, lo que resulta en que este valor cambie a 0.|
| `FECHA_BAJA`        | `DATE`       | -                | Sí     | Fecha en la que el usuario fue dado de baja del sistema. |
| `MATRICULA1`        | `VARCHAR2`   | 6                | Sí     | Campo no utilizado de propósito desconocido. Valor `NULL` en todos los registros de la tabla. |
| `PWD_HEX`           | `VARCHAR2`   | 100              | Sí     | Campo que almacena la contraseña hasheada en formato MD5. **Este campo es crucial para el proceso de autenticación de la aplicación móvil.** |

## Almacenamiento de la contraseña
**Metodo de hashing**: se identificó que el dato almacenado en la base de datos en el campo `PWD_HEX` es un hash MD5.

**Salting**: fue observado que el hash almacenado **NO** fue creado con salting. Esto se comprobó realizando el proceso de comparar los valores de `PWD_HEX` antes y despues de cambiar la contraseña a una temporal y volver a cambiarla a la contraseña original.
El proceso realizado se detalla a continuación.
1. Registrar el valor de `PWD_HEX`.
2. Ingresar al Sistema CGA como un usuario de prueba.
3. Reestablecer la contraseña (se genera y se cambia la contraseña a una temporal que el usuario puede utilizar para ingresar. En la tabla de usuarios el valor de `PWD_HEX` cambia).
4. Volver a ingresar la contraseña origianl como la nueva contraseña (el valor de `PWD_HEX` cambia nuevamente).
5. Registrar el valor de `PWD_HEX` y compararlo con el que se registró anteriormente.

**Nota: La falta de salting deja a los usuarios vulnerables frente a ataques que busquen obtener la contraseña asociada a un hash, por ejemplo, ataques utilizando Rainbow Tables. Es por esto que una posible mejora a futuro en cuanto a la autenticación es el agregado de un string aleatorio (salt) antes de calcular el hash de las contraseñas almacenadas. Luego, se almacenaría también este valor para poder utilizarlo a la hora de autenticar un usuario.**

## Relaciones con otras tablas
La tabla de usuarios no posee relaciones explícitas con otras tablas en la base de datos utilizando claves foráneas. A la hora de realizar consultas que requieran información de esta tabla se realiza una operación `JOIN` utilizando el valor de la columna `NRO_AFILIADO` como intermediario, el cual es un campo común para la mayor parte de las tablas.

La ausencia de claves foráneas se presenta en todas las tablas de esta base de datos del Sistema CGA, y representa un riesgo considerable en lo que respecta a mantener la integridad referencial de los datos. La responsabilidad de mantener la integridad recae en la implementación de la lógica de negocios del sistema, por lo que debe tenerse en cuenta en el desarrollo del proyecto.