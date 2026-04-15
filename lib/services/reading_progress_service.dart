import 'package:shared_preferences/shared_preferences.dart';

/// Clave de almacenamiento: 'read_chapters' → Set de strings 'bookId:chapter'
class ReadingProgressService {
  static const _key = 'read_chapters';

  static String _id(int bookId, int chapter) => '$bookId:$chapter';

  /// Marca un capítulo como leído. Retorna true si fue nuevo (no estaba marcado).
  static Future<bool> markChapterRead(int bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final set = prefs.getStringList(_key)?.toSet() ?? {};
    final id = _id(bookId, chapter);
    if (set.contains(id)) return false;
    set.add(id);
    await prefs.setStringList(_key, set.toList());
    return true;
  }

  /// Retorna el set de capítulos leídos como 'bookId:chapter'
  static Future<Set<String>> getReadChapters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  /// Verifica si un capítulo específico está leído
  static Future<bool> isChapterRead(int bookId, int chapter) async {
    final set = await getReadChapters();
    return set.contains(_id(bookId, chapter));
  }

  /// Retorna cuántos capítulos leídos tiene un libro
  static Future<int> getReadCountForBook(int bookId) async {
    final set = await getReadChapters();
    return set.where((s) => s.startsWith('$bookId:')).length;
  }

  /// Retorna el total de capítulos leídos en toda la Biblia
  static Future<int> getTotalRead() async {
    final set = await getReadChapters();
    return set.length;
  }

  /// Retorna los capítulos leídos de un libro como lista de ints
  static Future<List<int>> getReadChaptersForBook(int bookId) async {
    final set = await getReadChapters();
    return set
        .where((s) => s.startsWith('$bookId:'))
        .map((s) => int.parse(s.split(':')[1]))
        .toList()
      ..sort();
  }
}
