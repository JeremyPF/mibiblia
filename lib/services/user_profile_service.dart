import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPlan {
  final int minutesPerDay;
  final String readingTime; // 'morning' | 'afternoon' | 'night'
  final String startBook;
  final String motivationalMessage;
  final List<String> tips;

  const ReadingPlan({
    required this.minutesPerDay,
    required this.readingTime,
    required this.startBook,
    required this.motivationalMessage,
    required this.tips,
  });

  Map<String, dynamic> toJson() => {
        'minutesPerDay': minutesPerDay,
        'readingTime': readingTime,
        'startBook': startBook,
        'motivationalMessage': motivationalMessage,
        'tips': tips,
      };

  factory ReadingPlan.fromJson(Map<String, dynamic> j) => ReadingPlan(
        minutesPerDay: j['minutesPerDay'] as int,
        readingTime: j['readingTime'] as String,
        startBook: j['startBook'] as String,
        motivationalMessage: j['motivationalMessage'] as String,
        tips: List<String>.from(j['tips'] as List),
      );

  String get readingTimeLabel {
    switch (readingTime) {
      case 'morning': return 'Por la mañana';
      case 'afternoon': return 'Por la tarde';
      default: return 'Por la noche';
    }
  }
}

class UserProfileService {
  static const _keyFirstTime = 'first_time';
  static const _keyPlan = 'reading_plan';
  static const _keyAssessment = 'assessment_answers';

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  static Future<void> completeOnboarding(
    Map<String, int> answers,
    ReadingPlan plan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
    await prefs.setString(_keyAssessment, jsonEncode(answers));
    await prefs.setString(_keyPlan, jsonEncode(plan.toJson()));
  }

  static Future<ReadingPlan?> getSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPlan);
    if (raw == null) return null;
    return ReadingPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Resetea el onboarding (útil para testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstTime);
    await prefs.remove(_keyPlan);
    await prefs.remove(_keyAssessment);
  }
}
