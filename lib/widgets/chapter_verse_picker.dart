import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';

/// Abre el selector de capítulo y versículo como bottom sheet.
/// Retorna {bookId, bookName, chapter, verse} o null si se cancela.
Future<Map<String, dynamic>?> showChapterVersePicker(
    BuildContext context, BibleBook book) {
  return showGeneralDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'picker',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => _ChapterVersePickerSheet(book: book),
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

class _ChapterVersePickerSheet extends StatefulWidget {
  final BibleBook book;
  const _ChapterVersePickerSheet({required this.book});

  @override
  State<_ChapterVersePickerSheet> createState() =>
      _ChapterVersePickerSheetState();
}

class _ChapterVersePickerSheetState extends State<_ChapterVersePickerSheet> {
  int? _selectedChapter;
  int _verseCount = 0;
  bool _loadingVerses = false;

  Future<void> _onChapterTap(int chapter) async {
    setState(() { _selectedChapter = chapter; _loadingVerses = true; });
    final ch = await BibleService.loadChapter(widget.book.id, chapter);
    if (mounted) {
      setState(() {
        _verseCount = ch?.verses.length ?? 0;
        _loadingVerses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Column(children: [
                Center(child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 12),
                Row(children: [
                  if (_selectedChapter != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedChapter = null; _verseCount = 0;
                      }),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 16, color: AppTheme.secondary),
                    ),
                  if (_selectedChapter != null) const SizedBox(width: 8),
                  Text(
                    _selectedChapter == null
                        ? widget.book.name
                        : '${widget.book.name}  ·  Cap. $_selectedChapter',
                    style: GoogleFonts.newsreader(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.15), height: 1),
            Flexible(
              child: _selectedChapter == null
                  ? _buildChapterGrid()
                  : _buildVerseGrid(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildChapterGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8,
          childAspectRatio: 1),
      itemCount: widget.book.chapters,
      itemBuilder: (_, i) {
        final n = i + 1;
        return GestureDetector(
          onTap: () => _onChapterTap(n),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
            ),
            alignment: Alignment.center,
            child: Text('$n',
                style: GoogleFonts.newsreader(
                    fontSize: 14, color: AppTheme.secondary)),
          ),
        );
      },
    );
  }

  Widget _buildVerseGrid() {
    if (_loadingVerses) {
      return const Center(child: CircularProgressIndicator(
          color: AppTheme.secondary));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8,
          childAspectRatio: 1),
      itemCount: _verseCount,
      itemBuilder: (_, i) {
        final n = i + 1;
        return GestureDetector(
          onTap: () => Navigator.of(context).pop({
            'bookId': widget.book.id,
            'bookName': widget.book.name,
            'chapter': _selectedChapter!,
            'verse': n,
          }),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.outlineVariant.withOpacity(0.2)),
            ),
            alignment: Alignment.center,
            child: Text('$n',
                style: GoogleFonts.newsreader(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface
                        .withOpacity(0.7))),
          ),
        );
      },
    );
  }
}
