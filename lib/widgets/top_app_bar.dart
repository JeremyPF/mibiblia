import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopAppBar extends StatelessWidget {
  final double opacity;
  final String? bookName;
  final int? chapterNumber;
  final bool showSubtitle;

  const TopAppBar({
    super.key,
    this.opacity = 0.6,
    this.bookName,
    this.chapterNumber,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(opacity.clamp(0.0, 1.0)),
        border: showSubtitle
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.outlineVariant.withOpacity(0.15),
                  width: 1,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: SizedBox(
          height: showSubtitle ? 64 : 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Título + subtítulo centrados
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: showSubtitle && bookName != null
                    ? Column(
                        key: const ValueKey('with-subtitle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MiBiblia',
                            style:
                                Theme.of(context).appBarTheme.titleTextStyle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${bookName!.toUpperCase()}  ·  $chapterNumber',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.secondary.withOpacity(0.8),
                                  letterSpacing: 2.5,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        key: const ValueKey('title-only'),
                        'MiBiblia',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
              ),
              // Menú izquierda
              Positioned(
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.secondary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              // Búsqueda derecha
              Positioned(
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.secondary),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
