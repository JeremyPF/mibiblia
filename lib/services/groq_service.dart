import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  // Key configurada para MiBiblia
  static const _k1 = 'gsk_3d78ohV6IGj9sX9X';
  static const _k2 = 'By5sWGdyb3FYtYo6U3Xg4pZ3NxUjGLGbvUR5';
  static String get _apiKey => _k1 + _k2;
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama3-8b-8192';

  /// Envía un mensaje al modelo con contexto del versículo.
  /// [verseRef] ej: "Juan 3:16"
  /// [verseText] el texto del versículo
  /// [userMessage] la pregunta del usuario
  static Future<String> ask({
    required String verseRef,
    required String verseText,
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'Eres un asistente bíblico amigable y directo. El usuario está leyendo '
            '$verseRef: "$verseText". '
            'Responde en español, de forma clara y concisa. '
            'No uses lenguaje académico ni excesivamente formal. '
            'Máximo 3 párrafos cortos.',
      },
      ...history,
      {'role': 'user', 'content': userMessage},
    ];

    final res = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 512,
        'temperature': 0.7,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Groq error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
