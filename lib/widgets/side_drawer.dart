import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';
import '../screens/reading_screen.dart';
import '../screens/search_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/saved_verses_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/modo_ia_screen.dart';
import 'settings_modal.dart';
import 'chapter_verse_picker.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  List<BibleBook> _books = [];
  // null = todos, 'OT' = AT, 'NT' = NT
  String? _filter;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await BibleService.getAvailableBooks();
    if (mounted) setState(() => _books = books);
  }

  List<BibleBook> get _filtered {
    if (_filter == null) return _books;
    return _books.where((b) => b.testament == _filter).toList();
  }

  void _openBookPicker(BibleBook book) async {
    // Capture navigator before closing drawer
    final nav = Navigator.of(context, rootNavigator: true);
    final scaffoldContext = context;
    Navigator.of(context).pop(); // close drawer

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final result = await showChapterVersePicker(scaffoldContext, book);
    if (result == null) return;

    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          bookId: result['bookId'],
          bookName: result['bookName'],
          chapterNumber: result['chapter'],
          initialVerse: result['verse'] ?? 1,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 16, 16),
              child: Row(children: [
                Expanded(
                  child: Text('MiBiblia',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 24, fontStyle: FontStyle.italic)),
                ),
                // Modo IA button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ModoIAScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 13, color: AppTheme.secondary),
                      const SizedBox(width: 5),
                      Text('Modo IA',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
            // Filtro AT / NT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
                _FilterTab('Todos', _filter == null,
                    () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterTab('A.T.', _filter == 'OT',
                    () => setState(() => _filter = 'OT')),
                const SizedBox(width: 8),
                _FilterTab('N.T.', _filter == 'NT',
                    () => setState(() => _filter = 'NT')),
              ]),
            ),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.2), height: 1),
            const SizedBox(height: 4),
            Expanded(
              child: _books.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final book = _filtered[i];
                        return ListTile(
                          dense: true,
                          title: Text(book.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 16)),
                          subtitle: Text(
                            book.testament == 'OT'
                                ? 'Antiguo Testamento'
                                : 'Nuevo Testamento',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: AppTheme.outline,
                                    letterSpacing: 1.0),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onTap: () => _openBookPicker(book),
                        );
                      },
                    ),
            ),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.2), height: 1),
            _DrawerAction(Icons.bookmark_border, 'Guardados', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SavedVersesScreen()));
            }),
            _DrawerAction(Icons.edit_note, 'Anotaciones', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotesScreen()));
            }),
            _DrawerAction(Icons.bar_chart_outlined, 'Progreso', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProgressScreen()));
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListTile(
                leading: const Icon(Icons.settings_outlined,
                    color: AppTheme.secondary),
                title: Text('Ajustes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16, color: AppTheme.secondary)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  Navigator.of(context).pop();
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

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterTab(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.secondary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? AppTheme.secondary
                  : AppTheme.outlineVariant.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: selected
                    ? AppTheme.secondary
                    : AppTheme.outline.withOpacity(0.6),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerAction(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.secondary),
        title: Text(label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16, color: AppTheme.secondary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
