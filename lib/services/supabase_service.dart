import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _url = 'https://zrcyfrnkbcfxddfaeush.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyY3lmcm5rYmNmeGRkZmFldXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyOTkzNTQsImV4cCI6MjA5MTg3NTM1NH0.mAWmUkUau69sSG4LY3LhDc55Z5d_aZ0H10VOpaZKMYU';

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  /// Deriva un userId estable a partir del email (sha256, primeros 32 chars).
  static String emailToUserId(String email) {
    final bytes = utf8.encode(email.trim().toLowerCase());
    return 'email_${sha256.convert(bytes).toString().substring(0, 32)}';
  }

  static bool get isLinked => false; // sin auth real, se controla desde ReadingProgressService

  /// Sube el progreso a Supabase.
  static Future<void> uploadProgress(String userId, Set<String> readChapters) async {
    try {
      await _client.from('reading_progress').upsert({
        'user_id': userId,
        'data': {'chapters': readChapters.toList()},
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Descarga el progreso desde Supabase.
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

  /// Migra el progreso anónimo al userId del correo y lo fusiona con lo remoto.
  static Future<void> migrateToEmail(
      String anonId, String emailUserId, Set<String> localChapters) async {
    final remote = await downloadProgress(emailUserId) ?? {};
    final merged = {...localChapters, ...remote};
    await uploadProgress(emailUserId, merged);
    // Limpiar registro anónimo
    try {
      await _client.from('reading_progress').delete().eq('user_id', anonId);
    } catch (_) {}
  }
}
