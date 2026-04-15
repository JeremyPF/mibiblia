import 'package:flutter/material.dart';
import 'screens/reading_screen.dart';
import 'theme/app_theme.dart';
import 'providers/reading_settings_provider.dart';
import 'services/bible_service.dart';

void main() {
  runApp(const SacredTextApp());
}

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
          home: const _StartupScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

/// Carga el primer libro disponible y navega a ReadingScreen
class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  @override
  void initState() {
    super.initState();
    _loadFirstBook();
  }

  Future<void> _loadFirstBook() async {
    final books = await BibleService.getAvailableBooks();
    if (!mounted) return;
    final book = books.isNotEmpty ? books.first : null;
    if (book == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          bookId: book.id,
          bookName: book.name,
          chapterNumber: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
