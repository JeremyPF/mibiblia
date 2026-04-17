import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class ReadingProgressService {
  static const _key          = 'read_chapters';
  static const _anonIdKey    = 'anon_user_id';
  static const _emailKey     = 'linked_email';
  static const _pinKey       = 'account_pin';
  static const _pendingSyncKey = 'pending_sync';

  static String _id(int bookId, int chapter) => '$bookId:$chapter';

  // ── userId ────────────────────────────────────────────────────────────────

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    if (email != null && email.isNotEmpty) {
      return SupabaseService.emailToUserId(email);
    }
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

  static Future<bool> isEmailLinked() async {
    final prefs = await SharedPreferences.getInstance();
    final e = prefs.getString(_emailKey);
    return e != null && e.isNotEmpty;
  }

  static Future<String?> getLinkedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Vincula un correo: migra el progreso anónimo y guarda el email.
  static Future<void> linkEmail(String email, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final anonId = await getAnonId();
    final local = await getReadChapters();
    final emailUserId = SupabaseService.emailToUserId(email);
    await SupabaseService.migrateToEmail(anonId, emailUserId, local);
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_pinKey, pin);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  static Future<bool> verifyPin(String pin) async {
    return (await getPin()) == pin;
  }

  /// Desvincula el correo y borra el PIN.
  static Future<void> unlinkEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_pinKey);
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  static Future<void> syncFromCloud() async {
    final uid = await getUserId();
    final remote = await SupabaseService.downloadProgress(uid);
    if (remote == null || remote.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_key)?.toSet() ?? {};
    final merged = {...local, ...remote};
    await prefs.setStringList(_key, merged.toList());
  }

  static void _syncOrQueue(Set<String> chapters) async {
    try {
      final uid = await getUserId();
      await SupabaseService.uploadProgress(uid, chapters);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, false);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, true);
    }
  }

  static Future<void> flushPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_pendingSyncKey) != true) return;
    final set = prefs.getStringList(_key)?.toSet() ?? {};
    if (set.isEmpty) return;
    final uid = await getUserId();
    await SupabaseService.uploadProgress(uid, set);
    await prefs.setBool(_pendingSyncKey, false);
  }

  // ── Progreso ──────────────────────────────────────────────────────────────

  /// Marca un capítulo como leído. Retorna true si fue nuevo.
  static Future<bool> markChapterRead(int bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final set = prefs.getStringList(_key)?.toSet() ?? {};
    final id = _id(bookId, chapter);
    if (set.contains(id)) return false;
    set.add(id);
    await prefs.setStringList(_key, set.toList());
    _syncOrQueue(set);
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
