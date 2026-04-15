import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'providers/reading_settings_provider.dart';

void main() {
  runApp(const SacredTextApp());
}

// InheritedWidget para exponer el provider en todo el árbol
class ReadingSettingsScope extends InheritedNotifier<ReadingSettingsProvider> {
  const ReadingSettingsScope({
    super.key,
    required ReadingSettingsProvider settings,
    required super.child,
  }) : super(notifier: settings);

  static ReadingSettingsProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ReadingSettingsScope>()!
        .notifier!;
  }
}

class SacredTextApp extends StatefulWidget {
  const SacredTextApp({super.key});

  @override
  State<SacredTextApp> createState() => _SacredTextAppState();
}

class _SacredTextAppState extends State<SacredTextApp> {
  final ReadingSettingsProvider _settings = ReadingSettingsProvider();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReadingSettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp(
          title: 'MiBiblia',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
