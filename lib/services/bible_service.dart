import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter.dart';
import '../models/bible_book.dart';

class BibleService {
  // Cache para los capítulos cargados
  static final Map<String, dynamic> _cache = {};
  
  // Libros disponibles (con contenido JSON)
  static final List<int> _availableBooks = [20, 40, 43]; // Proverbios, Mateo, Juan

  /// Obtiene la lista de libros disponibles con contenido
  static Future<List<BibleBook>> getAvailableBooks() async {
    final List<BibleBook> books = [];
    
    for (int bookId in _availableBooks) {
      try {
        final fileName = 'sample_${bookId}_${_getBookFileName(bookId)}.json';
        final String jsonString = await rootBundle.loadString(
          'assets/data/$fileName',
        );
        final Map<String, dynamic> bookData = json.decode(jsonString);
        
        books.add(BibleBook(
          id: bookData['bookId'],
          name: bookData['bookName'],
          testament: bookData['testament'],
          chapters: (bookData['chapters'] as List).length,
          icon: _getIconForBook(bookId),
        ));
      } catch (e) {
        print('Error loading book $bookId: $e');
      }
    }
    
    return books;
  }

  /// Carga un libro completo desde los assets
  static Future<Map<String, dynamic>?> loadBook(int bookId) async {
    final key = 'book_$bookId';
    
    // Verificar cache
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final fileName = 'sample_${bookId}_${_getBookFileName(bookId)}.json';
      final String jsonString = await rootBundle.loadString(
        'assets/data/$fileName',
      );
      
      final Map<String, dynamic> bookData = json.decode(jsonString);
      _cache[key] = bookData;
      return bookData;
    } catch (e) {
      print('Error loading book $bookId - $e');
      return null;
    }
  }

  /// Carga un capítulo específico desde los assets
  static Future<Chapter?> loadChapter(int bookId, int chapterNumber) async {
    final key = '${bookId}_$chapterNumber';
    
    // Verificar cache
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final bookData = await loadBook(bookId);
      if (bookData == null) {
        print('Book data is null for bookId: $bookId');
        return null;
      }
      
      final List<dynamic> chapters = bookData['chapters'];
      print('Total chapters in book $bookId: ${chapters.length}');
      
      // Buscar el capítulo específico
      final chapterData = chapters.firstWhere(
        (ch) => ch['chapterNumber'] == chapterNumber,
        orElse: () => null,
      );
      
      if (chapterData != null) {
        print('Found chapter $chapterNumber with ${chapterData['verses'].length} verses');
        
        // Agregar bookId al chapterData
        final Map<String, dynamic> chapterWithBookId = {
          'bookId': bookId,
          'chapterNumber': chapterData['chapterNumber'],
          'verses': chapterData['verses'],
        };
        
        final chapter = Chapter.fromJson(chapterWithBookId);
        _cache[key] = chapter;
        return chapter;
      } else {
        print('Chapter $chapterNumber not found in book $bookId');
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Error loading chapter $bookId:$chapterNumber - $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Limpia el cache
  static void clearCache() {
    _cache.clear();
  }

  /// Verifica si un libro está disponible
  static bool isBookAvailable(int bookId) {
    return _availableBooks.contains(bookId);
  }

  static String _getBookFileName(int bookId) {
    switch (bookId) {
      case 20:
        return 'proverbios';
      case 40:
        return 'mateo';
      case 43:
        return 'juan';
      default:
        return 'unknown';
    }
  }

  static String _getIconForBook(int bookId) {
    if (bookId >= 1 && bookId <= 39) {
      if (bookId == 19) return 'music_note'; // Salmos
      if (bookId == 20) return 'history_edu'; // Proverbios
      return 'history_edu';
    } else {
      if (bookId >= 40 && bookId <= 44) return 'auto_stories'; // Evangelios y Hechos
      if (bookId >= 45 && bookId <= 65) return 'mail'; // Epístolas
      if (bookId == 66) return 'visibility'; // Apocalipsis
      return 'book';
    }
  }
}
