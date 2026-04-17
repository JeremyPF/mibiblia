import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/reading_progress_service.dart';
import '../services/bible_service.dart';
import '../data/bible_data.dart';
import '../models/bible_book.dart';
import '../widgets/email_link_dialog.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalBibleChapters = 1189;

  List<BibleBook> _availableBooks = [];
  Map<int, int> _readPerBook = {}; // bookId → chapters read
  int _totalRead = 0;
  bool _loading = true;

  late AnimationController _animCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _progressAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _loadProgress();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final books = await BibleService.getAvailableBooks();
    final total = await ReadingProgressService.getTotalRead();
    final Map<int, int> perBook = {};
    for (final book in books) {
      perBook[book.id] = await ReadingProgressService.getReadCountForBook(book.id);
    }
    if (!mounted) return;
    setState(() {
      _availableBooks = books;
      _readPerBook = perBook;
      _totalRead = total;
      _loading = false;
    });
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progreso',
            style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gráfico circular — Biblia completa
                  _buildBibleProgress(),
                  const SizedBox(height: 40),
                  // Barras por libro
                  _buildBookBars(),
                  const SizedBox(height: 40),
                  // Tabla de capítulos leídos
                  _buildChapterTable(),
                  const SizedBox(height: 40),
                  // Cuenta vinculada
                  _buildAccountSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildBibleProgress() {
    final percent = _totalRead / _totalBibleChapters;
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) => SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de progreso
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: percent * _progressAnim.value,
                      strokeWidth: 10,
                      backgroundColor:
                          AppTheme.outlineVariant.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.secondary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Texto central
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_totalRead).toString()}',
                        style: GoogleFonts.notoSerif(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'de $_totalBibleChapters',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.outline,
                              letterSpacing: 1.5,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'CAPÍTULOS LEÍDOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.secondary,
                  letterSpacing: 2.5,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${((_totalRead / _totalBibleChapters) * 100).toStringAsFixed(1)}% de la Biblia',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: AppTheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookBars() {
    if (_availableBooks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POR LIBRO',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary,
                letterSpacing: 2.5,
              ),
        ),
        const SizedBox(height: 20),
        ..._availableBooks.map((book) {
          final read = _readPerBook[book.id] ?? 0;
          final total = book.chapters;
          final pct = total > 0 ? read / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(book.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 15)),
                    Text(
                      '$read / $total',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct * _progressAnim.value,
                      minHeight: 6,
                      backgroundColor:
                          AppTheme.outlineVariant.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        read == total && total > 0
                            ? AppTheme.secondary
                            : AppTheme.secondary.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChapterTable() {
    if (_availableBooks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETALLE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary,
                letterSpacing: 2.5,
              ),
        ),
        const SizedBox(height: 16),
        ..._availableBooks.map((book) => _BookChapterGrid(book: book)),
      ],
    );
  }

  Widget _buildAccountSection() {
    return FutureBuilder<bool>(
      future: ReadingProgressService.isEmailLinked(),
      builder: (context, snap) {
        final linked = snap.data ?? false;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CUENTA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.secondary, letterSpacing: 2.5)),
          const SizedBox(height: 16),
          if (!linked)
            _AccountCard(
              icon: Icons.mail_outline,
              title: 'Sin cuenta vinculada',
              subtitle: 'Vincula un correo para guardar tu progreso en la nube.',
              action: 'Vincular',
              onAction: () async {
                await showEmailLinkDialog(context);
                setState(() {});
              },
            )
          else
            FutureBuilder<String?>(
              future: ReadingProgressService.getLinkedEmail(),
              builder: (ctx, emailSnap) {
                final email = emailSnap.data ?? '';
                return _AccountCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.secondary,
                  title: 'CUENTA VINCULADA',
                  subtitle: email,
                  action: 'Desvincular',
                  actionDestructive: true,
                  onAction: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('¿Desvincular cuenta?'),
                        content: const Text(
                            'Tu progreso seguirá guardado localmente.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Desvincular',
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ReadingProgressService.unlinkEmail();
                      if (mounted) setState(() {});
                    }
                  },
                );
              },
            ),
        ]);
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final String action;
  final bool actionDestructive;
  final VoidCallback onAction;

  const _AccountCard({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.action,
    this.actionDestructive = false,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.outlineVariant.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor ?? AppTheme.outline.withOpacity(0.5), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: iconColor ?? AppTheme.outline,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.outline.withOpacity(0.7))),
          ]),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(action,
              style: TextStyle(
                  color: actionDestructive ? Colors.red : AppTheme.secondary,
                  fontSize: 13)),
        ),
      ]),
    );
  }
}

class _BookChapterGrid extends StatefulWidget {
  final BibleBook book;
  const _BookChapterGrid({required this.book});

  @override
  State<_BookChapterGrid> createState() => _BookChapterGridState();
}

class _BookChapterGridState extends State<_BookChapterGrid> {
  Set<int> _readChapters = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chapters =
        await ReadingProgressService.getReadChaptersForBook(widget.book.id);
    if (mounted) {
      setState(() {
        _readChapters = chapters.toSet();
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(height: 40);
    final total = widget.book.chapters;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.outline,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(total, (i) {
              final chap = i + 1;
              final isRead = _readChapters.contains(chap);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isRead
                      ? AppTheme.secondary
                      : AppTheme.outlineVariant.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isRead
                        ? AppTheme.secondary
                        : AppTheme.outlineVariant.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$chap',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: isRead
                          ? AppTheme.onSecondary
                          : AppTheme.outline.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
