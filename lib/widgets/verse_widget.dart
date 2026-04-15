import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VerseWidget extends StatefulWidget {
  final int number;
  final String text;
  final bool isHighlighted;
  final Function(int verseNumber, String text)? onVerseLongPress;

  const VerseWidget({
    super.key,
    required this.number,
    required this.text,
    this.isHighlighted = false,
    this.onVerseLongPress,
  });

  @override
  State<VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<VerseWidget> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    Widget content = GestureDetector(
      onLongPress: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        if (_isSelected && widget.onVerseLongPress != null) {
          widget.onVerseLongPress!(widget.number, widget.text);
        }
      },
      child: Container(
        padding: widget.isHighlighted
            ? const EdgeInsets.symmetric(horizontal: 32, vertical: 48)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: _isSelected
              ? AppTheme.secondary.withOpacity(0.15)
              : (widget.isHighlighted ? AppTheme.surfaceContainerLow : Colors.transparent),
          border: widget.isHighlighted
              ? const Border(
                  left: BorderSide(
                    color: AppTheme.secondary,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: _buildVerseContent(context, italic: widget.isHighlighted),
      ),
    );

    return content;
  }

  Widget _buildVerseContent(BuildContext context, {bool italic = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.number}  ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.outline,
                  fontSize: 10,
                ),
          ),
          TextSpan(
            text: widget.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  backgroundColor: _isSelected
                      ? AppTheme.secondary.withOpacity(0.2)
                      : Colors.transparent,
                ),
          ),
        ],
      ),
    );
  }
}
