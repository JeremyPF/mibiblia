import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _url = 'https://zrcyfrnkbcfxddfaeush.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyY3lmcm5rYmNmeGRkZmFldXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyOTkzNTQsImV4cCI6MjA5MTg3NTM1NH0.mAWmUkUau69sSG4LY3LhDc55Z5d_aZ0H10VOpaZKMYU';

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLinked => currentUser != null;

  /// Envía un OTP al correo. El usuario lo ingresa para verificar.
  static Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  /// Verifica el OTP ingresado por el usuario.
  static Future<bool> verifyOtp(String email, String token) async {
    try {
      final res = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      return res.user != null;
    } catch (_) {
      return false;
    }
  }

  /// Sube el progreso. Usa el userId autenticado si existe, si no el anónimo.
  static Future<void> uploadProgress(String userId, Set<String> readChapters) async {
    try {
      await _client.from('reading_progress').upsert({
        'user_id': userId,
        'data': {'chapters': readChapters.toList()},
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Descarga el progreso desde la nube.
  static Future<Set<String>?> downloadProgress(String userId) async {
    try {
      final row = await _client
          .from('reading_progress')
          .select('data')
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) return null;
      final list = (row['data']['chapters'] as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return null;
    }
  }

  /// Migra el progreso anónimo al usuario autenticado tras vincular el correo.
  static Future<void> migrateAnonProgress(
      String anonId, Set<String> localChapters) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    // Descargar progreso previo del usuario autenticado (si existe)
    final remote = await downloadProgress(uid) ?? {};
    final merged = {...localChapters, ...remote};
    await uploadProgress(uid, merged);
    // Eliminar el registro anónimo
    try {
      await _client.from('reading_progress').delete().eq('user_id', anonId);
    } catch (_) {}
  }
}
