import 'package:supabase_flutter/supabase_flutter.dart';

/// Sincroniza el progreso de lectura con Supabase.
/// Usa un user_id anónimo persistido en local para identificar al usuario.
class SupabaseService {
  static const _url = 'https://zrcyfrnkbcfxddfaeush.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyY3lmcm5rYmNmeGRkZmFldXNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyOTkzNTQsImV4cCI6MjA5MTg3NTM1NH0.mAWmUkUau69sSG4LY3LhDc55Z5d_aZ0H10VOpaZKMYU';

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  /// Sube el set de capítulos leídos a la nube.
  static Future<void> uploadProgress(String userId, Set<String> readChapters) async {
    try {
      await _client.from('reading_progress').upsert({
        'user_id': userId,
        'data': {'chapters': readChapters.toList()},
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Fallo silencioso — el progreso local siempre es la fuente de verdad
    }
  }

  /// Descarga el progreso desde la nube. Retorna null si no hay datos.
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
}
