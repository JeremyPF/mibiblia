# MiBiblia

Una aplicación personal de lectura bíblica con diseño editorial elegante, basada en Flutter.

## Características

- Diseño editorial minimalista inspirado en publicaciones impresas
- Experiencia de lectura inmersiva con tipografía cuidadosamente seleccionada
- Navegación intuitiva entre libros, capítulos y versículos
- Sistema de marcadores para guardar versículos favoritos
- Soporte para modo claro y oscuro

## Estructura del Proyecto

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── models/
│   ├── bible_book.dart
│   └── verse.dart
├── screens/
│   └── reading_screen.dart
└── widgets/
    ├── top_app_bar.dart
    ├── bottom_nav_bar.dart
    └── verse_widget.dart
```

## Etapas de Desarrollo

### Etapa 1: Creación del Proyecto ✓
- Estructura básica del proyecto
- Sistema de diseño y tema
- Pantalla de lectura principal

### Etapa 2: Diseño de Escenas ✓
- Navegador de libros con todos los 66 libros bíblicos
- Selector de capítulos y versículos (modal)
- Pantalla de búsqueda y marcadores
- Pantalla de configuración con ajustes de lectura
- Drawer lateral para navegación desktop
- Navegación funcional entre pantallas

### Etapa 3: Compilación (Listo para aprobación)
- Configuración de GitHub Actions para Android e iOS
- Archivos de configuración Android listos
- Workflow automatizado para builds

## Nota Legal

Esta aplicación es para uso personal exclusivamente y no será distribuida públicamente.

**IMPORTANTE:** Asegúrate de tener los derechos apropiados para cualquier contenido bíblico que uses. The Message (MSG) y otras traducciones modernas están protegidas por derechos de autor. Considera usar traducciones de dominio público como Reina-Valera 1909 o APIs bíblicas con licencias apropiadas.
