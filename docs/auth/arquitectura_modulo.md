# Documentación de la Arquitectura: Módulo de Autenticación

Este documento detalla la arquitectura específica del módulo de Autenticación. La implementación se adhiere a los principios de Arquitectura Limpia (Clean Architecture) definidos en la [documentación de la arquitectura general](/docs/arquitectura_general.md), organizando el código en las capas de Presentación, Dominio y Datos.

El objetivo de este módulo es gestionar todos los aspectos relacionados con la identidad del usuario: inicio de sesión, cierre de sesión, recuperación de contraseña, cambio de contraseña y verificación del estado de la sesión.

## Capa de Presentación (Presentation)

Es la responsable de la interfaz de usuario (UI) y la gestión del estado local de la misma. Se comunica con la capa de Dominio a través de **Providers** para ejecutar acciones y reaccionar a los cambios de estado.

### Componentes Principales

#### Vistas (Screens/Widgets)

Son los componentes visuales con los que el usuario interactúa.

- `splash_screen.dart`: Pantalla de carga inicial. Verifica si el usuario ya tiene una sesión activa para decidir si dirigirlo a la pantalla de login o a la pantalla home.

- `login.dart`: Contiene la interfaz para el inicio de sesión. Utiliza los widgets `login_form.dart` para el formulario de credenciales y `login_biometric.dart` para la autenticación biométrica.

- `recuperar_password.dart`: Pantalla para que el usuario ingrese su correo electrónico y solicitar la recuperación de contraseña.

- `envio_email.dart`: Pantalla informativa que se muestra después de solicitar la recuperación de contraseña.

- `cambiar_password.dart`: Permite al usuario establecer una nueva contraseña.

- `password_actualizada.dart`: Pantalla de confirmación de que la contraseña se ha actualizado correctamente.

- `home.dart`: Pantalla principal a la que se accede tras una autenticación exitosa.

#### Gestores de Estado (Providers)

Se utiliza `Riverpod` para la gestión de estado y la inyección de dependencias. Los providers orquestan las interacciones del usuario, llaman a los casos de uso de la capa de Dominio y exponen el estado a la UI.

- `auth_provider.dart`: Gestiona el estado de autenticación global (`AuthState`), los datos del usuario (`UsuarioEntity`) y la lógica de login, logout y verificación de sesión.

- `password_recovery_provider.dart`: Maneja el estado y la lógica para el flujo de recuperación de contraseña.

- `cambiar_password_provider.dart`: Administra el estado y la lógica para el cambio de contraseña.

- `biometric_provider.dart`: Gestiona la disponibilidad y el uso de la autenticación biométrica.

## Capa de Dominio (Domain)

Contiene la lógica de negocio pura del módulo de autenticación, sin depender de ninguna implementación externa (UI o base de datos).

### Componentes Principales

#### Entidades (Entities)

Representan los objetos de negocio centrales.

- `usuario_entity.dart`: Modela al usuario autenticado, conteniendo su token y otros datos relevantes para la sesión.

- `datos_usuario_entity.dart`: Modela los datos específicos del perfil del usuario.

#### Repositorios (Interfaces Abstractas)

Definen los contratos que la capa de Datos debe implementar. Describen qué se puede hacer, pero no cómo.

- `usuario_repository.dart`: Define las operaciones relacionadas con el usuario, como `login`, `logout`, `recuperarPassword`, `cambiarPassword`, etc.

- `preferencias_repository.dart`: Define las operaciones para guardar y leer preferencias del usuario, como el estado de la autenticación biométrica.

#### Casos de Uso (Use Cases)

Encapsulan una única regla de negocio o una tarea específica. Son invocados por los **Providers** de la capa de Presentación.

- `login_use_case.dart`: Orquesta la lógica para iniciar sesión.

- `recuperar_password_use_case.dart`: Maneja la lógica para el proceso de recuperación de contraseña.

- `cambiar_password_use_case.dart`: Contiene la lógica para actualizar la contraseña del usuario.

- `verificar_estado_autenticacion_use_case.dart`: Se encarga de comprobar si existe un token de sesión válido.

## Capa de Datos (Data)

Implementa los repositorios definidos en la capa de Dominio. Es la responsable de obtener los datos de las fuentes correspondientes (API, almacenamiento local) y de transformar esos datos en las Entidades que el Dominio entiende.

### Componentes Principales

#### Repositorios (Implementaciones)

Clases concretas que implementan las interfaces de la capa de Dominio.

- `usuario_repository_impl.dart`: Implementación de `UsuarioRepository`. Coordina `UsuarioDataSource` y `SecureStorageDataSource` para realizar el login, guardar el token y gestionar los datos del usuario.

- `preferencias_repository_impl.dart`: Implementación de `PreferenciasRepository`. Utiliza `PreferenciasDataSource` para gestionar las preferencias del usuario.

#### Fuentes de Datos (Data Sources)

Clases que interactúan directamente con una única fuente de datos.

- `usuario_data_source.dart`: responsable de toda la comunicación con la API REST para las operaciones de autenticación.

- `secure_storage_data_source.dart`: se encarga de la lectura y escritura segura de datos sensibles (como el token de autenticación) utilizando `flutter_secure_storage`.

- `preferencias_data_source.dart`: gestiona el almacenamiento de datos no sensibles (preferencias del usuario) utilizando `shared_preferences`.

#### Modelos (Models)

Representan la estructura de los datos tal como se reciben de la API. Incluyen métodos `fromJson` para el parseo de las respuestas JSON. Cada archivo incluye los modelos relacionados.

- `auth_response_models.dart`

- `datos_usuario_response_models.dart`

- `recuperar_password_response_models.dart`

- `cambiar_password_response_models.dart`

#### Mapeadores (Mappers)

Funciones o clases responsables de convertir los **Models** de la capa de Datos en **Entities** de la capa de Dominio. Esto asegura que el Dominio permanezca aislado de los detalles de la fuente de datos.

- `cambiar_password_response_mapper.dart`: transforma un `CambiarPasswordResponseModel` en la entidad correspondiente si fuera necesario (en este caso, se usa directamente).

## Flujo de datos: ejemplo de Inicio de Sesión

Para ilustrar cómo interactúan las capas, a continuación se describe el flujo de un inicio de sesión exitoso:

1. Presentación: el usuario presiona el botón "Ingresar" en `login_form.dart`.

2. Presentación: el `AuthProvider` es notificado y llama al método `login` con el email y la contraseña.

3. Presentación -> Dominio: el `AuthProvider` invoca al `LoginUseCase`.

4. Dominio: el `LoginUseCase` llama al método `login` del `UsuarioRepository` (la interfaz).

5. Dominio -> Datos: la inyección de dependencias provee la implementación `UsuarioRepositoryImpl`, que recibe la llamada.

6. Datos: `UsuarioRepositoryImpl` llama a `UsuarioDataSource` para realizar la petición a la API.

7. Datos: `UsuarioDataSource` ejecuta la petición POST. Si es exitosa, parsea la respuesta JSON en un `AuthResponseModel`.

8. Datos: `UsuarioRepositoryImpl` recibe el `AuthResponseModel`. Llama al método `fromJson` de `UsuarioEntity` para mapear la respuesta a una entidad.

9. Datos: `UsuarioRepositoryImpl` invoca a `SecureStorageDataSource` para guardar de forma segura el token de la `UsuarioEntity`.

10. Datos -> Dominio: `UsuarioRepositoryImpl` retorna la `UsuarioEntity` al `LoginUseCase`.

11. Dominio -> Presentación: El `LoginUseCase` retorna la `UsuarioEntity` al `AuthProvider`.

12. Presentación: El `AuthProvider` actualiza su estado a un `AuthStatus` autenticado (con o sin preferencia de biometría) y almacena la `UsuarioEntity`. La UI reacciona a este cambio y navega a la pantalla `home.dart`.
