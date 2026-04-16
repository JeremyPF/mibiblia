import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class ReadingProgressService {
  static const _key = 'read_chapters';
  static const _anonIdKey = 'anon_user_id';
  static const _pendingSyncKey = 'pending_sync';

  static String _id(int bookId, int chapter) => '$bookId:$chapter';

  /// Retorna el userId efectivo: autenticado si existe, anónimo si no.
  static Future<String> getUserId() async {
    if (SupabaseService.isLinked) return SupabaseService.currentUser!.id;
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString(_anonIdKey);
    if (uid == null) {
      uid = 'anon_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_anonIdKey, uid);
    }
    return uid;
  }

  static Future<String> getAnonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonIdKey) ?? '';
  }

  /// Sincroniza desde la nube al arrancar. Fusiona remoto + local.
  static Future<void> syncFromCloud() async {
    final uid = await getUserId();
    if (uid.isEmpty) return;
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
    // Intentar sync en background; si falla, marcar pendiente
    _syncOrQueue(set);
    return true;
  }

  static void _syncOrQueue(Set<String> chapters) async {
    try {
      final uid = await getUserId();
      await SupabaseService.uploadProgress(uid, chapters);
      // Limpiar flag de pendiente si subió bien
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, false);
    } catch (_) {
      // Sin internet: marcar como pendiente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, true);
    }
  }

  /// Llama esto cuando se detecta que volvió la conexión.
  static Future<void> flushPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_pendingSyncKey) != true) return;
    final set = prefs.getStringList(_key)?.toSet() ?? {};
    if (set.isEmpty) return;
    final uid = await getUserId();
    await SupabaseService.uploadProgress(uid, set);
    await prefs.setBool(_pendingSyncKey, false);
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
