# Documentación la arquitectura general de la aplicación

## Arquitectura

Para el desarrollo de cada módulo de la aplicación se decidió implementar una **Arquitectura Limpia (Clean Architecture)**. Esta decisión estratégica permite organizar el código en capas independientes, cada una con una responsabilidad clara, promoviendo un sistema desacoplado, mantenible y fácilmente testeable.

Las capas definidas son: **Presentación (Interfaz de Usuario)**, **Dominio (Lógica de Negocio)** y **Datos (Acceso a Datos)**.

---

### Capa de Presentación (Presentation)

Esta capa es responsable de todo lo relacionado con la interfaz de usuario (UI, por sus siglas en inglés) y la gestión de su estado. No contiene lógica de negocio; su función es mostrar datos al usuario y capturar sus interacciones para delegarlas a la capa de dominio.

#### Vistas (Screens/Widgets)

Las vistas son los componentes visuales que el usuario final observa y con los que interactúa. En el contexto de una aplicación Flutter, estas vistas están compuestas por **Widgets**.

Su principal responsabilidad es:

- Renderizar la interfaz de usuario basándose en el estado actual que reciben de los proveedores.
- Capturar las interacciones del usuario (como toques en botones, ingreso de texto, etc.).
- Notificar a los gestores de estado (proveedores) sobre estas interacciones para que la lógica correspondiente sea ejecutada.

Las vistas deben contener la menor cantidad de lógica de negocio posible. Simplemente reflejan el estado de la aplicación y delegan todas las decisiones y procesamiento de datos a las capas correspondientes.

#### Gestión de Estado (Riverpod)

En la capa de presentación, para gestionar el estado de la autenticación del usuario de manera eficiente, reactiva y desacoplada, utilizamos el patrón Provider que nos ofrece el paquete flutter_riverpod. Este patrón se basa en la interacción de tres componentes clave:

- El **Estado**: Representa el "Qué". Su única responsabilidad es contener la información del estado de autenticación en un momento específico. Es inmutable, una vez creado un objeto de la clase **Estado** no se modifica, sino que para cambiar el estado se crea una nueva instancia. Contiene datos que la UI necesita para dibujarse correctamente.

- El **Notificador**: Representa el "Cómo". Es quien contiene la lógica de negocio de la UI. Se encarga de definir cómo responder a los eventos del usuario y cómo cambiar de estado.

- El **Proveedor**: Representa el "Dónde". Es el puente de comunicación entre las vistas y el **Notificador**. Es global e inmutable y permite que la UI lea el **Estado** y acceda a las acciones del **Notificador**.

---

### Capa de Dominio (Domain)

Contiene la lógica de negocio fundamental y las reglas que definen el funcionamiento del sistema, independientemente de la interfaz de usuario (Presentación) o de dónde se almacenen los datos (Datos).
La principal regla de esta capa es su independencia, no debe contener ninguna dependencia de las demás capas.

Está compuesta por tres elementos principales **Entidades**, **Repositorios (Abstracciones)** y **Casos de Uso**.

#### Entidades (Entities)

Son los objetos de negocio principales, y representan la estructura de datos y conceptos fundamentales.
Son clases simples, que no contienen lógica de frameworks y son utilizados por los **Casos de Uso** y la **Capa de Presentacion** sin importar el origen de los datos.

#### Respositorios (Repositories)

En esta capa los repositorios son contratos abstractos (interfaces, clases abstractas), definen _qué_ operaciones (funciones, métodos) se pueden realizar con los datos pero no _cómo_ se realizan.
La implementación concreta de estas abstracciones se encuentra en la **Capa de Datos**.

#### Casos de uso (Use Cases)

Son clases que encapsulan una pieza de lógica de negocio única y específica.
Se encargan de orquestar el flujo de datos entre las entidades y los repositorios.
Son el punto de entrada a la **Capa de Dominio** desde la **Capa de Presentacion**.

---

### Capa de Datos (Data)

Es la responsable de la obtención y el almacenamiento de los datos, para lo cual implementa los contratos abstractos (repositorios) definidos en al **Capa de Dominio**.
Esta capa es quien conoce el origen de los datos, ya sea una API remota, una base de datos u otro tipo de almacén de datos.

Está compuesta por **Repositorios (Implementaciones)**, **Fuentes de datos**, **Modelos** y **Mapeadores**.

#### Respositorios (Respositories)

Estas son las clases concretas que implementan las interfaces de los repositorios definidos en la **Capa de Dominio**.
Su función principal es orquestar las diferentes fuentes de datos para cumplir con la solicitud del dominio.
Actúa como un coordinador, desacoplando la lógica de negocio de los detalles de implementación de dónde y cómo se obtienen y guardan los datos.

#### Fuentes de Datos (Data Sources)

Son las clases que interactúan directamente con un único tipo de fuentes de datos, realizando las operaciones de más bajo nivel de la aplicación.

#### Modelos de Datos (Models)

Son clases que representan la estructura exacta de los datos tal como se reciben de una fuente. Se diferencian de las Entidades en que pueden contener campos específicos de la fuente de datos que no son relevantes para la lógica de negocio.

#### Mapeadores (Mappers)

Son clases o funciones auxiliares que se encargan de transformar datos de un formato a otro.
