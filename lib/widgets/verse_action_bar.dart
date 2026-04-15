import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/share_service.dart';

class VerseActionBar extends StatelessWidget {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;
  final VoidCallback onClose;
  final Function(int verseNumber, String text) onSave;
  final Function(int verseNumber, String text) onAddNote;

  const VerseActionBar({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
    required this.onClose,
    required this.onSave,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Cerrar',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(context),
            tooltip: 'Compartir',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: verseText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Versículo copiado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Copiar',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              onSave(verseNumber, verseText);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Versículo guardado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Guardar',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              onAddNote(verseNumber, verseText);
            },
            tooltip: 'Escribir nota',
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Compartir versículo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: AppTheme.secondary),
              ),
              title: const Text('Compartir como imagen'),
              subtitle: const Text('Crea una imagen hermosa del versículo'),
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
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.text_fields, color: AppTheme.secondary),
              ),
              title: const Text('Compartir como texto'),
              subtitle: const Text('Comparte el versículo en formato texto'),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
