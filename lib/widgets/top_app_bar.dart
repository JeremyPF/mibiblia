import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/reading_progress_service.dart';
import '../widgets/email_link_dialog.dart';

class TopAppBar extends StatefulWidget {
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
  State<TopAppBar> createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(widget.opacity.clamp(0.6, 1.0)),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(
              widget.showSubtitle ? 0.15 : 0.0,
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
              IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.secondary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MiBiblia',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: widget.showSubtitle && widget.bookName != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: AnimatedOpacity(
                                opacity: widget.showSubtitle ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  '${widget.bookName!.toUpperCase()}  ·  ${widget.chapterNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.secondary.withOpacity(0.8),
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
              // Icono palpitante si no está vinculado
              FutureBuilder<bool>(
                future: ReadingProgressService.isEmailLinked(),
                builder: (context, snap) {
                  final linked = snap.data ?? true; // asumir vinculado hasta saber
                  if (linked) return const SizedBox.shrink();
                  return AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => IconButton(
                      icon: Icon(Icons.mail_outline,
                          color: AppTheme.secondary
                              .withOpacity(_pulseAnim.value),
                          size: 22),
                      tooltip: 'Vincular correo',
                      onPressed: () async {
                        await showEmailLinkDialog(context);
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.secondary),
                onPressed: widget.onSearchTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
