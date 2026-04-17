import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/share_service.dart';
import '../services/saved_verses_service.dart';
import '../models/highlight.dart';
import '../screens/notes_screen.dart';

class VerseActionBar extends StatelessWidget {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final VoidCallback onClose;
  final VoidCallback? onRefresh; // para actualizar badges en la pantalla

  const VerseActionBar({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.onClose,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
          const Spacer(),
          // Compartir
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(context),
            tooltip: 'Compartir',
          ),
          // Copiar
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: 'Copiar',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: verseText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Versículo copiado'),
                    duration: Duration(seconds: 2)),
              );
            },
          ),
          // Guardar con categoría
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Guardar',
            onPressed: () => _showSaveModal(context),
          ),
          // Añadir nota
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Anotación',
            onPressed: () => _showNoteEditor(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ── Guardar con selector de categoría ────────────────────────────────────

  Future<void> _showSaveModal(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'save',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => _SaveVerseSheet(
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        onSaved: () {
          onClose();
          onRefresh?.call();
        },
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  // ── Editor de notas ───────────────────────────────────────────────────────

  Future<void> _showNoteEditor(BuildContext context) async {
    await NoteEditorModal.show(
      context,
      bookName: bookName,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      verseText: verseText,
    );
    onRefresh?.call();
  }

  // ── Compartir ─────────────────────────────────────────────────────────────

  void _showShareOptions(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'share',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => _ShareSheet(
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }
}

// ── Save Verse Sheet ───────────────────────────────────────────────────────

class _SaveVerseSheet extends StatefulWidget {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final VoidCallback onSaved;

  const _SaveVerseSheet({
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.onSaved,
  });

  @override
  State<_SaveVerseSheet> createState() => _SaveVerseSheetState();
}

class _SaveVerseSheetState extends State<_SaveVerseSheet> {
  List<VerseCategory> _cats = [];
  String? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await SavedVersesService.getCategories();
    if (mounted) setState(() { _cats = cats; _selected = cats.first.name; _loading = false; });
  }

  Future<void> _save() async {
    final cat = _cats.firstWhere((c) => c.name == _selected,
        orElse: () => _cats.first);
    await SavedVersesService.save(Highlight(
      id: '${widget.bookName}_${widget.chapterNumber}_${widget.verseNumber}',
      bookName: widget.bookName,
      chapterNumber: widget.chapterNumber,
      verseNumber: widget.verseNumber,
      verseText: widget.verseText,
      createdAt: DateTime.now(),
      category: cat.name,
      color: cat.color,
    ));
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.outlineVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.bookmark_border,
                    color: AppTheme.secondary, size: 18),
                const SizedBox(width: 8),
                Text('Guardar versículo',
                    style: GoogleFonts.newsreader(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              // Preview del versículo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.verseText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.newsreader(
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const CircularProgressIndicator(color: AppTheme.secondary)
              else ...[
                Text('Categoría',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.outline, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _cats.map((c) {
                    final color = Color(c.color);
                    final sel = _selected == c.name;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = c.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? color.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? color : color.withOpacity(0.35)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(c.name,
                              style: GoogleFonts.newsreader(
                                  fontSize: 13,
                                  color: sel ? color : color.withOpacity(0.7),
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14)),
                    child: Text('Guardar',
                        style: GoogleFonts.newsreader(fontSize: 15)),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Share Sheet ────────────────────────────────────────────────────────────

class _ShareSheet extends StatelessWidget {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;

  const _ShareSheet({
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.outlineVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Compartir versículo',
                  style: GoogleFonts.newsreader(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _ShareOption(
                icon: Icons.image,
                title: 'Como imagen',
                subtitle: 'Crea una imagen hermosa del versículo',
                onTap: () async {
                  Navigator.pop(context);
                  await ShareService.shareVerseAsImage(
                    context: context,
                    bookName: bookName,
                    chapterNumber: chapterNumber,
                    verseNumber: verseNumber,
                    verseText: verseText,
                  );
                },
              ),
              _ShareOption(
                icon: Icons.text_fields,
                title: 'Como texto',
                subtitle: 'Comparte en formato texto',
                onTap: () async {
                  Navigator.pop(context);
                  await ShareService.shareVerseAsText(
                    bookName: bookName,
                    chapterNumber: chapterNumber,
                    verseNumber: verseNumber,
                    verseText: verseText,
                  );
                },
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOption({required this.icon, required this.title,
      required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.secondary),
      ),
      title: Text(title, style: GoogleFonts.newsreader(fontSize: 15)),
      subtitle: Text(subtitle,
          style: GoogleFonts.newsreader(
              fontSize: 12, color: AppTheme.outline)),
      onTap: onTap,
    );
  }
}
