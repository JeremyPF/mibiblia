import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/saved_verses_service.dart';
import '../screens/notes_screen.dart';

class VerseWidget extends StatefulWidget {
  final int number;
  final String text;
  final bool isHighlighted;
  final Function(int verseNumber, String text)? onVerseLongPress;
  final String? bookName;
  final int? chapterNumber;

  const VerseWidget({
    super.key,
    required this.number,
    required this.text,
    this.isHighlighted = false,
    this.onVerseLongPress,
    this.bookName,
    this.chapterNumber,
  });

  @override
  State<VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<VerseWidget>
    with SingleTickerProviderStateMixin {
  bool _isSelected = false;
  late AnimationController _controller;
  late Animation<double> _highlightAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _highlightAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    setState(() => _isSelected = !_isSelected);
    if (_isSelected) {
      _controller.forward();
      widget.onVerseLongPress?.call(widget.number, widget.text);
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ReadingSettingsScope.of(context);
    final textStyle = AppTheme.bodyStyle(
      fontFamily: settings.fontFamily,
      fontSize: settings.fontSize,
      height: settings.lineHeight,
      letterSpacing: settings.letterSpacing,
      color: settings.textColor,
      fontStyle: widget.isHighlighted ? FontStyle.italic : FontStyle.normal,
    );

    return GestureDetector(
      onLongPress: _handleLongPress,
      child: AnimatedBuilder(
        animation: _highlightAnim,
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: widget.isHighlighted
                ? const EdgeInsets.symmetric(horizontal: 32, vertical: 48)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _isSelected
                  ? AppTheme.secondary.withOpacity(0.12 * _highlightAnim.value)
                  : (widget.isHighlighted
                      ? AppTheme.surfaceContainerLow
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(4 * _highlightAnim.value),
              border: widget.isHighlighted
                  ? const Border(
                      left: BorderSide(color: AppTheme.secondary, width: 2))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: settings.textAlign,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.number}  ',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.outline.withOpacity(0.7),
                              fontSize: 10,
                            ),
                      ),
                      TextSpan(
                        text: widget.text,
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
                if (widget.bookName != null)
                  FutureBuilder<List>(
                    future: Future.wait([
                      NotesService.getForVerse(
                          widget.bookName!, widget.chapterNumber!, widget.number),
                      SavedVersesService.getForVerse(
                          widget.bookName!, widget.chapterNumber!, widget.number)
                          .then((h) => h != null ? [h] : []),
                    ]),
                    builder: (ctx, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final notes = snap.data![0];
                      final saved = snap.data![1];
                      if (notes.isEmpty && saved.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, left: 18),
                        child: Wrap(spacing: 8, runSpacing: 4, children: [
                          if (notes.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                NoteEditorModal.show(ctx, note: notes[0]);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.secondary.withOpacity(0.25)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.edit_note_rounded,
                                      size: 11,
                                      color: AppTheme.secondary.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    notes.length == 1
                                        ? (notes[0].noteText as String).length > 28
                                            ? '${(notes[0].noteText as String).substring(0, 28)}…'
                                            : notes[0].noteText as String
                                        : '${notes.length} notas',
                                    style: Theme.of(ctx).textTheme.labelSmall
                                        ?.copyWith(
                                          fontSize: 10,
                                          color: AppTheme.secondary.withOpacity(0.8),
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ]),
                              ),
                            ),
                          if (saved.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Color((saved[0] as dynamic).color)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Color((saved[0] as dynamic).color)
                                        .withOpacity(0.35)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.bookmark_rounded,
                                    size: 10,
                                    color: Color((saved[0] as dynamic).color)
                                        .withOpacity(0.8)),
                                const SizedBox(width: 4),
                                Text(
                                  (saved[0] as dynamic).category as String,
                                  style: Theme.of(ctx).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: Color((saved[0] as dynamic).color)
                                            .withOpacity(0.8),
                                      ),
                                ),
                              ]),
                            ),
                        ]),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
