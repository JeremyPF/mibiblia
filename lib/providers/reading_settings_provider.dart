import 'package:flutter/material.dart';

class ReadingSettingsProvider extends ChangeNotifier {
  double fontSize = 20.0;
  double lineHeight = 2.0;
  double letterSpacing = 0.0;
  bool isDarkMode = false;
  TextAlign textAlign = TextAlign.left;
  Color textColor = const Color(0xFF2E342F);

  void setFontSize(double v) { fontSize = v; notifyListeners(); }
  void setLineHeight(double v) { lineHeight = v; notifyListeners(); }
  void setLetterSpacing(double v) { letterSpacing = v; notifyListeners(); }
  void setDarkMode(bool v) {
    isDarkMode = v;
    textColor = v ? const Color(0xFFDEE4DC) : const Color(0xFF2E342F);
    notifyListeners();
  }
  void setTextAlign(TextAlign v) { textAlign = v; notifyListeners(); }
  void setTextColor(Color v) { textColor = v; notifyListeners(); }
}
