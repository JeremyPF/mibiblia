import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSettingsProvider extends ChangeNotifier {
  double fontSize = 20.0;
  double lineHeight = 2.0;
  double letterSpacing = 0.0;
  bool isDarkMode = false;
  TextAlign textAlign = TextAlign.left;
  Color textColor = const Color(0xFF2E342F);
  String fontFamily = 'Newsreader';

  static const List<String> elegantFonts = [
    'Newsreader', 'Lora', 'Merriweather', 'Playfair Display',
    'EB Garamond', 'Cormorant Garamond', 'Libre Baskerville', 'Crimson Text',
  ];

  static const _kFontSize      = 'rs_fontSize';
  static const _kLineHeight    = 'rs_lineHeight';
  static const _kLetterSpacing = 'rs_letterSpacing';
  static const _kDarkMode      = 'rs_darkMode';
  static const _kTextAlign     = 'rs_textAlign';
  static const _kTextColor     = 'rs_textColor';
  static const _kFontFamily    = 'rs_fontFamily';

  /// Carga los ajustes guardados. Llama esto antes de runApp.
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    fontSize      = p.getDouble(_kFontSize)      ?? 20.0;
    lineHeight    = p.getDouble(_kLineHeight)     ?? 2.0;
    letterSpacing = p.getDouble(_kLetterSpacing)  ?? 0.0;
    isDarkMode    = p.getBool(_kDarkMode)         ?? false;
    textAlign     = TextAlign.values[p.getInt(_kTextAlign) ?? 0];
    textColor     = Color(p.getInt(_kTextColor)   ?? 0xFF2E342F);
    fontFamily    = p.getString(_kFontFamily)     ?? 'Newsreader';
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kFontSize,      fontSize);
    await p.setDouble(_kLineHeight,    lineHeight);
    await p.setDouble(_kLetterSpacing, letterSpacing);
    await p.setBool(_kDarkMode,        isDarkMode);
    await p.setInt(_kTextAlign,        textAlign.index);
    await p.setInt(_kTextColor,        textColor.value);
    await p.setString(_kFontFamily,    fontFamily);
  }

  void setFontSize(double v)      { fontSize = v;      notifyListeners(); _save(); }
  void setLineHeight(double v)    { lineHeight = v;    notifyListeners(); _save(); }
  void setLetterSpacing(double v) { letterSpacing = v; notifyListeners(); _save(); }
  void setDarkMode(bool v) {
    isDarkMode = v;
    textColor = v ? const Color(0xFFDEE4DC) : const Color(0xFF2E342F);
    notifyListeners();
    _save();
  }
  void setTextAlign(TextAlign v)  { textAlign = v;     notifyListeners(); _save(); }
  void setTextColor(Color v)      { textColor = v;     notifyListeners(); _save(); }
  void setFontFamily(String v)    { fontFamily = v;    notifyListeners(); _save(); }
}
