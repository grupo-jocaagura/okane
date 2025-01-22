# Okane
![Coverage](https://img.shields.io/badge/coverage-99%25-brightgreen)
![Coverage](https://img.shields.io/badge/Author-@albertjjimenezp-brightgreen)
-------------------------------![Author](https://avatars.githubusercontent.com/u/35118534?s=200&u=80708c1558e4e482d52d31490959442f618a2d62&v=4)----------🐱‍👤
# Proyecto Okane

## Descripción
**Okane** es una aplicación interactiva diseñada para ayudarte a gestionar tus finanzas de manera eficiente y clara. Este proyecto utiliza Flutter como tecnología principal, implementando las mejores prácticas de desarrollo con el patrón **BLoC** y testeando el paquete de jocaagura_domain asi como jocaaguraarchetype para la comunidad con el animo de fomentar su uso y explicar mejores practicas a nivel de desarrollo estandarizado de proyectos.

La estructura del proyecto está optimizada para garantizar modularidad, escalabilidad y un manejo claro de las responsabilidades.

---

## Estructura del Proyecto
La organización de archivos y carpetas sigue un enfoque basado en Clean Architecture, facilitando la separación de responsabilidades y el mantenimiento del código.

```
📁 lib
 ├── 📁 blocs
 │    └── 📄 example_bloc.dart
 ├── 📁 domain
 │    ├── 📁 entities
 │    │    └── 📄 table_counter.dart
 │    ├── 📁 repositories
 │    │    └── 📄 example_repository.dart
 ├── 📁 infrastructure
 │    ├── 📁 services
 │    │    └── 📄 example_service.dart
 ├── 📁 ui
 │    ├── 📁 theme
 │    │    └── 📄 app_theme.dart
 │    ├── 📁 views
 │    │    └── 📄 home_view.dart
 │    ├── 📁 widgets
 │         └── 📄 custom_button.dart
 └── 📄 main.dart
```
---
Diseño del Proyecto

El diseño interactivo de la aplicación está disponible en [Figma](https://www.figma.com/design/MjDb1KcxAIdl7dP2LDa81J/Okane-Interactivo?node-id=52815-6437). Este diseño proporciona una guía visual para la interfaz de usuario y la experiencia del usuario, asegurando que todas las partes interesadas estén alineadas en términos de apariencia y funcionalidad.

---

## Dependencias
El proyecto utiliza los siguientes paquetes desarrollados por **Jocaagura**:

### 1. **[jocaagura_domain](https://github.com/jocaagura/jocaagura_domain/blob/master/README.md)**
Este paquete proporciona abstracciones y modelos para gestionar la lógica de negocio y la estructura del dominio.
- **Características principales**:
    - Modelos inmutables como `UserModel`, `PersonModel` y `AddressModel`.
    - Utilidades como `DateUtils` y `Debouncer`.
    - Implementación de patrones funcionales como `Either`.
- **Ejemplo de Uso**:
```dart
import 'package:jocaagura_domain/user_model.dart';

void main() {
  var user = UserModel(
    id: '001',
    displayName: 'Juan Perez',
    email: 'juan.perez@example.com',
  );
  print(user);
}
```

### 2. **[jocaaguraarchetype](https://github.com/jocaagura/jocaaguraarchetype/blob/master/README.md)**
Este paquete facilita la integración de funcionalidades transversales al inicio de cada proyecto.
- **Características principales**:
    - Temas personalizables mediante `ProviderTheme` y `BlocTheme`.
    - Navegación centralizada con `BlocNavigator`.
    - Componentes de interfaz responsivos con `BlocResponsive`.
- **Ejemplo de Uso**:
```dart
import 'package:jocaaguraarchetype/bloc_navigator.dart';

void main() {
  BlocNavigator navigator = BlocNavigator(PageManager());
  navigator.pushPage('/home', HomePage());
}
```

---

## Planificación y Características Futuras
1. **Base de Datos Local**:
    - Se evaluará la implementación de un repositorio para gestionar los datos localmente.
    - Posibles opciones: SQLite o Hive.

2. **Integración con API**:
    - Se considera integrar servicios externos como Firebase o Google Script mediante un Gateway para centralizar las peticiones.

3. **Funciones de Finanzas Interactivas**:
    - Registro de gastos e ingresos.
    - Generación de reportes visuales personalizados.

---

## Contribuir
Si deseas contribuir al proyecto, puedes seguir estos pasos:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/jocaagura/okane.git
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Asegúrate de que las pruebas pasen correctamente:
   ```bash
   flutter test
   ```
4. Realiza un Pull Request con los cambios propuestos.

---

## Información Adicional
Para más información sobre los paquetes utilizados:
- [jocaagura_domain README](https://github.com/jocaagura/jocaagura_domain/blob/master/README.md)
- [jocaaguraarchetype README](https://github.com/jocaagura/jocaaguraarchetype/blob/master/README.md)
- [Play store](https://play.google.com/store/apps/details?id=co.com.okane.okane)
- [figma](https://www.figma.com/design/MjDb1KcxAIdl7dP2LDa81J/Okane-Interactivo?node-id=52815-6437)

Si tienes dudas o sugerencias, no dudes en comunicarte con el equipo de desarrollo.

---

**Nota**: Esta documentación es inicial y se actualizará a medida que el proyecto evolucione.
