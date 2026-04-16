import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class ReadingProgressService {
  static const _key = 'read_chapters';
  static const _userIdKey = 'anon_user_id';

  static String _id(int bookId, int chapter) => '$bookId:$chapter';

  /// Retorna (o genera) un userId anónimo persistido localmente.
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString(_userIdKey);
    if (uid == null) {
      uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_userIdKey, uid);
    }
    return uid;
  }

  /// Al arrancar la app: descarga progreso de la nube y lo fusiona con el local.
  static Future<void> syncFromCloud() async {
    final uid = await getUserId();
    final remote = await SupabaseService.downloadProgress(uid);
    if (remote == null || remote.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_key)?.toSet() ?? {};
    final merged = {...local, ...remote};
    await prefs.setStringList(_key, merged.toList());
  }

  /// Marca un capítulo como leído. Retorna true si fue nuevo.
  static Future<bool> markChapterRead(int bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final set = prefs.getStringList(_key)?.toSet() ?? {};
    final id = _id(bookId, chapter);
    if (set.contains(id)) return false;
    set.add(id);
    await prefs.setStringList(_key, set.toList());
    // Sync en background — no bloquea la UI
    getUserId().then((uid) => SupabaseService.uploadProgress(uid, set));
    return true;
  }

  static Future<Set<String>> getReadChapters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<bool> isChapterRead(int bookId, int chapter) async {
    final set = await getReadChapters();
    return set.contains(_id(bookId, chapter));
  }

  static Future<int> getReadCountForBook(int bookId) async {
    final set = await getReadChapters();
    return set.where((s) => s.startsWith('$bookId:')).length;
  }

  static Future<int> getTotalRead() async {
    final set = await getReadChapters();
    return set.length;
  }

  static Future<List<int>> getReadChaptersForBook(int bookId) async {
    final set = await getReadChapters();
    return set
        .where((s) => s.startsWith('$bookId:'))
        .map((s) => int.parse(s.split(':')[1]))
        .toList()
      ..sort();
  }
}
