import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';

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
            child: RichText(
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
          );
        },
      ),
    );
  }
}
