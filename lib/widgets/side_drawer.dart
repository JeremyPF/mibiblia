import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';
import '../screens/reading_screen.dart';
import 'settings_modal.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  List<BibleBook> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await BibleService.getAvailableBooks();
    if (mounted) setState(() => _books = books);
  }

  void _openBook(BibleBook book) {
    Navigator.of(context).pop(); // cerrar drawer
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
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Text(
                'MiBiblia',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            Divider(
              color: AppTheme.outlineVariant.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 8),
            // Lista de libros
            Expanded(
              child: _books.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return _BookTile(
                          book: book,
                          onTap: () => _openBook(book),
                        );
                      },
                    ),
            ),
            // Botón settings
            Divider(
              color: AppTheme.outlineVariant.withOpacity(0.2),
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(Icons.settings_outlined,
                    color: AppTheme.secondary),
                title: Text(
                  'Ajustes',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: AppTheme.secondary,
                      ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.of(context).pop(); // cerrar drawer
                  SettingsModal.show(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onTap;

  const _BookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        book.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      ),
      subtitle: Text(
        book.testament == 'OT' ? 'Antiguo Testamento' : 'Nuevo Testamento',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.outline,
              letterSpacing: 1.0,
            ),
      ),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
