# Guía de Contribución

¡Gracias por tu interés en contribuir a **Okane**! Para mantener un flujo de trabajo organizado y eficiente, sigue estas pautas.

---

## 🚀 Flujo de Trabajo

Este proyecto sigue un **Git Flow básico** para gestionar el desarrollo de manera estructurada:

1. \`\`: Rama protegida. Solo se actualiza a través de Merge Requests (MR) desde una rama base creada a partir de`develop` y recibe unicamente label de minor o major según sea el caso.
2. **`develop`**: Rama principal para desarrollo. Aquí se fusionan los Pull Requests (PR) de los desarrolladores.
3. **Ramas de desarrollo**: Los desarrolladores crean ramas a partir de `develop`, siguiendo la convención de nombres descrita más abajo.
4. **Pull Requests (PR)**: Se deben crear hacia `develop` y requieren revisión de al menos un revisor antes de fusionarse.

---

## 📂 Convenciones de Nomenclatura

Para mantener un historial limpio y coherente, seguimos las siguientes reglas:

### **1️⃣ Ramas**

Las ramas deben seguir la estructura:

```
[item]/nombre-descriptivo
```

Ejemplos:

- `feature/agregar-dashboard`
- `fix/corregir-bug-login`
- `patch/mejorar-renderizado`

**Tipos de rama:**

- `feature/` → Para nuevas funcionalidades.
- `fix/` → Para corrección de errores.
- `patch/` → Para mejoras menores o cambios pequeños.

### **2️⃣ Commits y Changelog**

El formato de commits sigue el estándar de **Keep a Changelog** y **Semantic Versioning**:

- `[Added]` Para nuevas funcionalidades.
- `[Changed]` Para cambios en funcionalidades existentes.
- `[Deprecated]` Para funciones que serán eliminadas pronto.
- `[Removed]` Para funciones que han sido eliminadas.
- `[Fixed]` Para correcciones de errores.
- `[Security]` Para correcciones de vulnerabilidades.

Ejemplo:

```
[Added] Implementación del sistema de autenticación.
[Fixed] Corregido error en la validación de formularios.
```

Cada cambio significativo debe registrarse en el `CHANGELOG.md`.

---

## 🔍 Revisión de Código

1. **Revisión por pares:** Cada PR debe ser revisado por al menos un desarrollador antes de ser fusionado.
2. **Checks automáticos:** Todos los PR deben pasar las validaciones de GitHub Actions antes de su aprobación.
3. **Correcciones:** Si un revisor sugiere cambios, estos deben ser aplicados antes de la aprobación final.

---

## 🔧 Reglas para Contribuir

### 1️⃣ Crear un Issue antes de empezar

Cada tarea debe estar vinculada a un **Issue** en GitHub. Usa etiquetas (`feature`, `bug`, `patch`) para clasificarla correctamente.

### 2️⃣ Crear una rama

Crea una nueva rama a partir de `develop` siguiendo la convención de nombres establecida.

### 3️⃣ Realizar cambios y pruebas

Antes de hacer un PR, asegúrate de:

- Pasar el análisis de código con `flutter analyze`.
- Ejecutar pruebas con `flutter test` --coverage.
- Mantener la consistencia del código con las reglas del linter.

### 4️⃣ Crear un Pull Request (PR)

- Asegúrate de describir los cambios en el PR.
- Vincula el Issue correspondiente.
- Espera la revisión y aprobación de al menos un revisor.

### 5️⃣ Merge a `develop`

Una vez aprobado, el PR puede fusionarse en `develop`. Si es un cambio crítico, planifica un release para fusionarlo en `master`.

---

## ✅ Checklist antes de hacer un PR

Antes de enviar un PR, verifica lo siguiente:

✅ La rama sigue la convención de nombres.

✅ Pasaron todas las pruebas (`flutter test`).

✅ La documentación relevante ha sido actualizada.

✅ El PR está vinculado a un Issue.


✅ Ha sido revisado por otro desarrollador.

---

Gracias por contribuir a **Okane** 🎉 ¡Tu esfuerzo hace que el proyecto sea mejor!
