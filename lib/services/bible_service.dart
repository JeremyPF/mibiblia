import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter.dart';

class BibleService {
  // Cache para los capítulos cargados
  static final Map<String, Chapter> _cache = {};

  /// Carga un capítulo específico desde los assets
  static Future<Chapter?> loadChapter(int bookId, int chapterNumber) async {
    final key = '${bookId}_$chapterNumber';
    
    // Verificar cache
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      // Cargar el archivo JSON del libro
      final String jsonString = await rootBundle.loadString(
        'assets/data/${bookId}_book.json',
      );
      
      final Map<String, dynamic> bookData = json.decode(jsonString);
      final List<dynamic> chapters = bookData['chapters'];
      
      // Buscar el capítulo específico
      final chapterData = chapters.firstWhere(
        (ch) => ch['chapterNumber'] == chapterNumber,
        orElse: () => null,
      );
      
      if (chapterData != null) {
        final chapter = Chapter.fromJson(chapterData);
        _cache[key] = chapter;
        return chapter;
      }
      
      return null;
    } catch (e) {
      print('Error loading chapter $bookId:$chapterNumber - $e');
      return null;
    }
  }

  /// Limpia el cache
  static void clearCache() {
    _cache.clear();
  }

  /// Verifica si un libro está disponible
  static Future<bool> isBookAvailable(int bookId) async {
    try {
      await rootBundle.load('assets/data/${bookId}_book.json');
      return true;
    } catch (e) {
      return false;
    }
  }
}
