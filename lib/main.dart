import 'package:flutter/material.dart';
import 'screens/reading_screen.dart';
import 'screens/search_screen.dart';
import 'theme/app_theme.dart';
import 'providers/reading_settings_provider.dart';
import 'services/bible_service.dart';
import 'services/update_service.dart';
import 'widgets/update_banner.dart';

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
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // Verificar actualizaciones al arrancar (con delay para no bloquear el inicio)
    Future.delayed(const Duration(seconds: 3), _updateService.checkForUpdates);
  }

  @override
  void dispose() {
    _settings.dispose();
    _updateService.dispose();
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
          debugShowCheckedModeBanner: false,
          builder: (context, child) => _AppShell(
            updateService: _updateService,
            child: child!,
          ),
          home: const _StartupScreen(),
        ),
      ),
    );
  }
}

/// Wrapper global que superpone el UpdateBanner en bottom-right
class _AppShell extends StatelessWidget {
  final UpdateService updateService;
  final Widget child;

  const _AppShell({required this.updateService, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 24,
          right: 16,
          child: UpdateBanner(service: updateService),
        ),
      ],
    );
  }
}

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
          onSearchTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
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
