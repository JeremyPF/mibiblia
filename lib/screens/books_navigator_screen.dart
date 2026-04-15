import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_drawer.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';
import 'chapter_selector_screen.dart';

class BooksNavigatorScreen extends StatefulWidget {
  const BooksNavigatorScreen({super.key});

  @override
  State<BooksNavigatorScreen> createState() => _BooksNavigatorScreenState();
}

class _BooksNavigatorScreenState extends State<BooksNavigatorScreen> {
  List<BibleBook> _availableBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
  }

  Future<void> _loadAvailableBooks() async {
    final books = await BibleService.getAvailableBooks();
    setState(() {
      _availableBooks = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: TopAppBar(opacity: 0.85),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda - Contexto
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 128, right: 64),
                          child: _buildLeftColumn(context),
                        ),
                      ),
                      // Columna derecha - Lista de libros
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 128),
                          child: _buildBooksColumn(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIBLIOTECA',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Libros Disponibles',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
              ),
        ),
        const SizedBox(height: 32),
        Text(
          'Explora los libros sagrados disponibles en tu biblioteca personal. Cada libro contiene sabiduría eterna para tu vida diaria.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                color: AppTheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_availableBooks.length} libros disponibles',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      color: AppTheme.secondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca cualquier libro para comenzar a leer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: AppTheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBooksColumn(BuildContext context) {
    final otBooks = _availableBooks.where((b) => b.testament == 'OT').toList();
    final ntBooks = _availableBooks.where((b) => b.testament == 'NT').toList();

    return Column(
      children: [
        if (otBooks.isNotEmpty)
          _buildTestamentSection(
            context,
            'I.',
            'Antiguo Testamento',
            otBooks,
          ),
        if (otBooks.isNotEmpty && ntBooks.isNotEmpty) const SizedBox(height: 96),
        if (ntBooks.isNotEmpty)
          _buildTestamentSection(
            context,
            'II.',
            'Nuevo Testamento',
            ntBooks,
          ),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildTestamentSection(
    BuildContext context,
    String number,
    String title,
    List<BibleBook> books,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.secondary,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 30,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        ...books.map((book) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildBookItem(context, book),
            )),
      ],
    );
  }

  Widget _buildBookItem(BuildContext context, BibleBook book) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterSelectorScreen(book: book),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.outlineVariant.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconData(book.icon),
                  color: AppTheme.secondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.chapters} capítulos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.secondary.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'history_edu':
        return Icons.history_edu;
      case 'music_note':
        return Icons.music_note;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'mail':
        return Icons.mail;
      case 'visibility':
        return Icons.visibility;
      default:
        return Icons.book;
    }
  }
}
