# Estructura de Datos Bíblicos

Esta carpeta contendrá los archivos JSON con el contenido bíblico.

## Formato de Archivos

Cada libro debe tener su propio archivo JSON con el siguiente formato:

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
          "text": "Texto del versículo aquí..."
        },
        {
          "number": 2,
          "text": "Texto del versículo aquí..."
        }
      ]
    }
  ]
}
```

## Archivos Necesarios

Para los Evangelios:
- `40_mateo.json` - Evangelio de Mateo (28 capítulos)
- `41_marcos.json` - Evangelio de Marcos (16 capítulos)
- `42_lucas.json` - Evangelio de Lucas (24 capítulos)
- `43_juan.json` - Evangelio de Juan (21 capítulos)

## Nota Importante sobre Derechos de Autor

**IMPORTANTE:** The Message (MSG) es una traducción con derechos de autor protegidos por NavPress y Tyndale House Publishers. No puedes reproducir, traducir o distribuir su contenido sin permiso explícito.

### Alternativas Legales:

1. **Reina-Valera 1909** - Dominio público
2. **Reina-Valera 1960** - Requiere permiso de Sociedades Bíblicas Unidas
3. **Traducción del Nuevo Mundo** - Dominio público en algunos países
4. **APIs Bíblicas con licencia:**
   - Bible API (https://bible-api.com/)
   - API.Bible (https://scripture.api.bible/)
   - YouVersion API (requiere aprobación)

### Para Uso Personal:

Si deseas crear tu propia paráfrasis personal:
- Puedes escribir tu propia interpretación basada en múltiples fuentes
- Debe ser sustancialmente diferente de cualquier traducción protegida
- Solo para uso personal, no distribución

### Recomendación:

Para este proyecto personal, te sugiero usar una traducción de dominio público o crear tus propias notas de estudio basadas en múltiples fuentes públicas.
