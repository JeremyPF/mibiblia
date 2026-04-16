import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../models/bible_book.dart';

class SearchResult {
  final int bookId;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;

  const SearchResult({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
  });
}

class BibleService {
  static final Map<String, dynamic> _cache = {};
  static final List<int> _availableBooks = [20, 40, 43];

  // Índice de búsqueda: palabra normalizada → lista de resultados
  static Map<String, List<SearchResult>>? _searchIndex;
  static bool _indexBuilding = false;

  static Future<List<BibleBook>> getAvailableBooks() async {
    final List<BibleBook> books = [];
    for (int bookId in _availableBooks) {
      try {
        final fileName = 'sample_${bookId}_${_getBookFileName(bookId)}.json';
        final String jsonString =
            await rootBundle.loadString('assets/data/$fileName');
        final Map<String, dynamic> bookData = json.decode(jsonString);
        books.add(BibleBook(
          id: bookData['bookId'],
          name: bookData['bookName'],
          testament: bookData['testament'],
          chapters: (bookData['chapters'] as List).length,
          icon: _getIconForBook(bookId),
        ));
      } catch (e) {
        debugPrint('Error loading book $bookId: $e');
      }
    }
    return books;
  }

  static Future<Map<String, dynamic>?> loadBook(int bookId) async {
    final key = 'book_$bookId';
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final fileName = 'sample_${bookId}_${_getBookFileName(bookId)}.json';
      final String jsonString =
          await rootBundle.loadString('assets/data/$fileName');
      final Map<String, dynamic> bookData = json.decode(jsonString);
      _cache[key] = bookData;
      return bookData;
    } catch (e) {
      debugPrint('Error loading book $bookId: $e');
      return null;
    }
  }

  static Future<Chapter?> loadChapter(int bookId, int chapterNumber) async {
    final key = '${bookId}_$chapterNumber';
    if (_cache.containsKey(key)) return _cache[key];
    try {
      final bookData = await loadBook(bookId);
      if (bookData == null) return null;
      final chapters = bookData['chapters'] as List<dynamic>;
      final chapterData = chapters.firstWhere(
        (ch) => ch['chapterNumber'] == chapterNumber,
        orElse: () => null,
      );
      if (chapterData == null) return null;
      final chapter = Chapter.fromJson({
        'bookId': bookId,
        'chapterNumber': chapterData['chapterNumber'],
        'verses': chapterData['verses'],
      });
      _cache[key] = chapter;
      return chapter;
    } catch (e) {
      debugPrint('Error loading chapter $bookId:$chapterNumber: $e');
      return null;
    }
  }

  // ── Búsqueda ──────────────────────────────────────────────────────────────

  /// Construye el índice en un isolate para no bloquear la UI
  static Future<void> buildSearchIndex() async {
    if (_searchIndex != null || _indexBuilding) return;
    _indexBuilding = true;

    // Cargar todos los libros disponibles
    final List<Map<String, dynamic>> allVerses = [];
    for (final bookId in _availableBooks) {
      final bookData = await loadBook(bookId);
      if (bookData == null) continue;
      final bookName = bookData['bookName'] as String;
      for (final chapter in bookData['chapters'] as List<dynamic>) {
        final chapterNum = chapter['chapterNumber'] as int;
        for (final verse in chapter['verses'] as List<dynamic>) {
          allVerses.add({
            'bookId': bookId,
            'bookName': bookName,
            'chapter': chapterNum,
            'verse': verse['number'] as int,
            'text': verse['text'] as String,
          });
        }
      }
    }

    // Construir índice en isolate para no bloquear la UI
    _searchIndex = await compute(_buildIndex, allVerses);
    _indexBuilding = false;
  }

  /// Busca una query en el índice. Retorna resultados ordenados por relevancia.
  static List<SearchResult> search(String query) {
    if (_searchIndex == null || query.trim().isEmpty) return [];

    final terms = _normalize(query).split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
    if (terms.isEmpty) return [];

    // Intersección de resultados para múltiples palabras
    // Para una sola palabra, búsqueda directa O(1)
    Set<SearchResult>? results;
    for (final term in terms) {
      final hits = <SearchResult>{};
      // Búsqueda exacta primero
      if (_searchIndex!.containsKey(term)) {
        hits.addAll(_searchIndex![term]!);
      }
      // Búsqueda por prefijo para el último término (autocompletado)
      if (term == terms.last) {
        for (final key in _searchIndex!.keys) {
          if (key.startsWith(term) && key != term) {
            hits.addAll(_searchIndex![key]!);
          }
        }
      }
      results = results == null ? hits : results.intersection(hits);
    }

    return (results ?? {}).take(100).toList();
  }

  static bool isBookAvailable(int bookId) => _availableBooks.contains(bookId);
  static bool get isIndexReady => _searchIndex != null;

  // ── Privados ──────────────────────────────────────────────────────────────

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static String _getBookFileName(int bookId) {
    switch (bookId) {
      case 20: return 'proverbios';
      case 40: return 'mateo';
      case 43: return 'juan';
      default: return 'unknown';
    }
  }

  static String _getIconForBook(int bookId) {
    if (bookId == 19) return 'music_note';
    if (bookId <= 39) return 'history_edu';
    if (bookId <= 44) return 'auto_stories';
    if (bookId <= 65) return 'mail';
    return 'visibility';
  }

  static void clearCache() => _cache.clear();
}

/// Función top-level para compute() — construye el índice invertido
Map<String, List<SearchResult>> _buildIndex(List<Map<String, dynamic>> verses) {
  final index = <String, List<SearchResult>>{};

  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  for (final v in verses) {
    final result = SearchResult(
      bookId: v['bookId'] as int,
      bookName: v['bookName'] as String,
      chapterNumber: v['chapter'] as int,
      verseNumber: v['verse'] as int,
      verseText: v['text'] as String,
    );

    final words = normalize(v['text'] as String)
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toSet(); // deduplicar palabras por versículo

    for (final word in words) {
      (index[word] ??= []).add(result);
    }
  }

  return index;
}
