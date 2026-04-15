# Instrucciones para Agregar Contenido Bíblico

## ⚠️ IMPORTANTE: Derechos de Autor

**The Message (MSG)** es una traducción con derechos de autor protegidos. No puedes:
- Reproducir su texto
- Traducir su contenido al español
- Distribuir copias (incluso para uso personal)

## Opciones Legales

### 1. Traducciones de Dominio Público
- **Reina-Valera 1909**: Completamente libre
- **Reina-Valera 1960**: Requiere permiso de Sociedades Bíblicas Unidas
- **Biblia de las Américas**: Requiere licencia

### 2. APIs Bíblicas Gratuitas
```
Bible API: https://bible-api.com/
- Soporta múltiples traducciones
- Uso gratuito con atribución
- Incluye versiones en español

API.Bible: https://scripture.api.bible/
- Requiere registro gratuito
- Múltiples traducciones
- Límites de uso razonables
```

### 3. Crear Tu Propia Paráfrasis
Si deseas crear tu propia versión:
- Debe ser sustancialmente diferente de cualquier traducción existente
- Basada en múltiples fuentes públicas
- Solo para uso personal, no distribución

## Formato de Archivos

Coloca tus archivos JSON en `assets/data/` con este formato:

```json
{
  "bookId": 40,
  "bookName": "Mateo",
  "testament": "NT",
  "chapters": [
    {
      "chapterNumber": 1,
      "verses": [
        {
          "number": 1,
          "text": "Tu texto aquí"
        }
      ]
    }
  ]
}
```

## Nombres de Archivos

- `40_book.json` - Mateo
- `41_book.json` - Marcos
- `42_book.json` - Lucas
- `43_book.json` - Juan

## Recomendación

Para tu uso personal, te sugiero:
1. Usar la API de Bible API con Reina-Valera 1909
2. O escribir tus propias notas de estudio basadas en múltiples fuentes públicas
3. Consultar con un abogado si planeas usar cualquier traducción moderna

## Recursos Útiles

- Sociedades Bíblicas Unidas: https://www.unitedbiblesocieties.org/
- Bible Gateway (para comparar traducciones): https://www.biblegateway.com/
- YouVersion (para ver qué traducciones están disponibles): https://www.bible.com/
