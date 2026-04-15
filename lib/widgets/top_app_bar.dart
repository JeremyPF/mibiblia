import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopAppBar extends StatelessWidget {
  final double opacity;
  final String? bookName;
  final int? chapterNumber;
  final bool showSubtitle;
  final VoidCallback? onSearchTap;

  const TopAppBar({
    super.key,
    this.opacity = 0.6,
    this.bookName,
    this.chapterNumber,
    this.showSubtitle = false,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(opacity.clamp(0.6, 1.0)),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(
              showSubtitle ? 0.15 : 0.0,
            ),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              // Menú izquierda
              IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.secondary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              // Título centrado (Expanded para ocupar el espacio restante)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MiBiblia',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    // Subtítulo animado in-place — no cambia la altura del navbar
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: showSubtitle && bookName != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: AnimatedOpacity(
                                opacity: showSubtitle ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  '${bookName!.toUpperCase()}  ·  $chapterNumber',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color:
                                            AppTheme.secondary.withOpacity(0.8),
                                        letterSpacing: 2.0,
                                        fontSize: 9,
                                      ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Búsqueda derecha
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.secondary),
                onPressed: onSearchTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
