import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/verse_widget.dart';
import '../widgets/side_drawer.dart';
import '../widgets/verse_action_bar.dart';
import '../widgets/note_dialog.dart';
import '../theme/app_theme.dart';
import '../models/highlight.dart';
import '../models/note.dart';
import '../models/chapter.dart';
import '../services/bible_service.dart';
import '../services/reading_progress_service.dart';
import '../data/bible_data.dart';
import '../services/user_profile_service.dart';
import 'search_screen.dart';

class ReadingScreen extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int chapterNumber;
  final VoidCallback? onSearchTap;

  const ReadingScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    this.onSearchTap,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  double _appBarOpacity = 0.0;
  bool _showSubtitle = false;

  // Capítulo actual (puede cambiar al navegar)
  late int _currentChapter;
  Chapter? _chapter;
  bool _isLoading = true;
  bool _chapterMarkedRead = false;

  // Animación de transición entre capítulos
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;
  bool _navigatingForward = true;

  int? _selectedVerseNumber;
  String? _selectedVerseText;
  final List<Highlight> _highlights = [];
  final List<Note> _notes = [];

  static const Map<int, Map<int, String>> _chapterTitles = {
    20: {
      1: 'El comienzo de la sabiduría', 2: 'Los beneficios de la sabiduría',
      3: 'Confía en el Señor', 4: 'La senda de los justos',
      5: 'Advertencia contra la inmoralidad', 6: 'Seis cosas que Dios aborrece',
      7: 'Advertencia contra la adultera', 8: 'El llamado de la sabiduría',
      9: 'La sabiduría y la necedad', 10: 'Proverbios de Salomón',
    },
    40: {
      1: 'La genealogía de Jesucristo', 2: 'La visita de los magos',
      3: 'Juan el Bautista', 4: 'La tentación de Jesús',
      5: 'El Sermón del Monte', 6: 'La oración del Señor',
      7: 'El árbol y sus frutos', 8: 'Jesús sana a muchos',
      9: 'La fe que sana', 10: 'Los doce apóstoles',
    },
    43: {
      1: 'El Verbo se hizo carne', 2: 'Las bodas de Caná',
      3: 'El nuevo nacimiento', 4: 'La mujer samaritana',
      5: 'La curación en el estanque', 6: 'El pan de vida',
      7: 'Jesús en la fiesta', 8: 'La mujer adúltera',
      9: 'El ciego de nacimiento', 10: 'El buen pastor',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
    _pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeInOut);
    _loadChapter();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageCtrl.dispose();
    _navDebounce?.cancel();
    super.dispose();
  }

  int get _totalChaptersInBook {
    final book = BibleData.getAllBooks()
        .firstWhere((b) => b.id == widget.bookId, orElse: () =>
            BibleData.getAllBooks().first);
    return book.chapters;
  }

  bool get _hasNextChapter =>
      BibleService.isBookAvailable(widget.bookId) &&
      _currentChapter < _totalChaptersInBook;

  bool get _hasPrevChapter => _currentChapter > 1;

  // Navegación por scroll al final/inicio
  Timer? _navDebounce;

  void _onScroll() {
    final pos = _scrollController.position;
    final current = pos.pixels;
    final maxScroll = pos.maxScrollExtent;

    setState(() {
      _scrollProgress = maxScroll > 0 ? (current / maxScroll).clamp(0.0, 1.0) : 0.0;
      _appBarOpacity = (current / 120).clamp(0.0, 1.0);
      _showSubtitle = current > 200;
    });

    // Marcar capítulo leído al 95%
    if (!_chapterMarkedRead && maxScroll > 100 && current >= maxScroll * 0.95) {
      _markCurrentChapterRead();
    }

    // Navegar al siguiente capítulo: scroll al fondo + indicador listo + 1.5s
    if (_indicatorReady && _hasNextChapter && maxScroll > 0 && current >= maxScroll) {
      _navDebounce?.cancel();
      _navDebounce = Timer(const Duration(milliseconds: 1500), () {
        if (_scrollController.hasClients &&
            _scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          _goToNextChapter();
        }
      });
    } else if (_hasPrevChapter && current <= 0) {
      // Navegar al capítulo anterior: scroll al tope + 1.5s
      _navDebounce?.cancel();
      _navDebounce = Timer(const Duration(milliseconds: 1500), () {
        if (_scrollController.hasClients &&
            _scrollController.position.pixels <= 0) {
          _goToPrevChapter();
        }
      });
    } else {
      _navDebounce?.cancel();
    }
  }

  // Estado del indicador de capítulo completado
  bool _showCompleteIndicator = false;
  bool _indicatorReady = false; // true = ya mostró el check, listo para flecha

  Future<void> _markCurrentChapterRead() async {
    if (_chapterMarkedRead) return;
    _chapterMarkedRead = true;
    await ReadingProgressService.markChapterRead(widget.bookId, _currentChapter);
    if (!mounted) return;
    setState(() => _showCompleteIndicator = true);
    // Después de 1.2s transiciona de check a flecha
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _indicatorReady = true);
    });
  }

  Future<void> _loadChapter({bool forward = true}) async {
    _navigatingForward = forward;
    _pageCtrl.reset();
    setState(() {
      _isLoading = true;
      _chapterMarkedRead = false;
      _showCompleteIndicator = false;
      _indicatorReady = false;
    });
    final chapter = await BibleService.loadChapter(widget.bookId, _currentChapter);
    if (!mounted) return;
    setState(() { _chapter = chapter; _isLoading = false; });
    // Guardar posición actual
    UserProfileService.saveLastPosition(widget.bookId, widget.bookName, _currentChapter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    _pageCtrl.forward();
  }

  void _goToNextChapter() {
    if (!_hasNextChapter) return;
    setState(() => _currentChapter++);
    _loadChapter(forward: true);
  }

  void _goToPrevChapter() {
    if (!_hasPrevChapter) return;
    setState(() => _currentChapter--);
    _loadChapter(forward: false);
  }

  void _handleVerseLongPress(int verseNumber, String verseText) {
    setState(() {
      if (_selectedVerseNumber == verseNumber) {
        _selectedVerseNumber = null;
        _selectedVerseText = null;
      } else {
        _selectedVerseNumber = verseNumber;
        _selectedVerseText = verseText;
      }
    });
  }

  void _handleSaveVerse(int verseNumber, String verseText) {
    setState(() {
      _highlights.add(Highlight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookName: widget.bookName,
        chapterNumber: _currentChapter,
        verseNumber: verseNumber,
        verseText: verseText,
        createdAt: DateTime.now(),
      ));
      _selectedVerseNumber = null;
      _selectedVerseText = null;
    });
  }

  void _handleAddNote(int verseNumber, String verseText) async {
    final noteText = await showDialog<String>(
      context: context,
      builder: (context) =>
          NoteDialog(verseNumber: verseNumber, verseText: verseText),
    );
    if (noteText != null && noteText.isNotEmpty) {
      setState(() {
        _notes.add(Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookName: widget.bookName,
          chapterNumber: _currentChapter,
          verseNumber: verseNumber,
          verseText: verseText,
          noteText: noteText,
          createdAt: DateTime.now(),
        ));
        _selectedVerseNumber = null;
        _selectedVerseText = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nota guardada'),
              duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedVerseNumber != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          opacity: _appBarOpacity.clamp(0.6, 1.0),
          bookName: widget.bookName,
          chapterNumber: _currentChapter,
          showSubtitle: _showSubtitle,
          onSearchTap: widget.onSearchTap ?? () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapter == null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Contenido con animación de transición entre capítulos
                    FadeTransition(
                      opacity: _pageFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(_navigatingForward ? 0.04 : -0.04, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: _pageCtrl, curve: Curves.easeOut)),
                        child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 800),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 100),
                                      _buildHeader(),
                                      const SizedBox(height: 80),
                                      _buildScriptureContent(),
                                      const SizedBox(height: 64),
                                      _buildChapterNav(),
                                      const SizedBox(height: 80),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ),
                    ),
                    // Indicador de progreso lateral
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: _ReadingProgressIndicator(
                          progress: _scrollProgress),
                    ),
                    // Indicador de capítulo completado
                    if (_showCompleteIndicator)
                      Positioned(
                        bottom: 32,
                        left: 0, right: 0,
                        child: Center(
                          child: _ChapterCompleteIndicator(
                            ready: _indicatorReady,
                            hasNext: _hasNextChapter,
                            onNext: _goToNextChapter,
                          ),
                        ),
                      ),
                    // VerseActionBar — bottom
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: AnimatedSlide(
                        offset: hasSelection
                            ? Offset.zero
                            : const Offset(0, 1),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: hasSelection ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: hasSelection
                              ? VerseActionBar(
                                  bookName: widget.bookName,
                                  chapterNumber: _currentChapter,
                                  verseNumber: _selectedVerseNumber!,
                                  verseText: _selectedVerseText!,
                                  onClose: () => setState(() {
                                    _selectedVerseNumber = null;
                                    _selectedVerseText = null;
                                  }),
                                  onSave: _handleSaveVerse,
                                  onAddNote: _handleAddNote,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.secondary),
          const SizedBox(height: 24),
          Text('No se pudo cargar el capítulo',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.onSecondary),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title = _chapterTitles[widget.bookId]?[_currentChapter];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.bookName.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppTheme.secondary)),
        const SizedBox(height: 16),
        Text(_currentChapter.toString(),
            style: Theme.of(context).textTheme.displayLarge),
        if (title != null) ...[
          const SizedBox(height: 12),
          Text(title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.outline,
                    fontWeight: FontWeight.w300,
                  )),
        ],
        const SizedBox(height: 32),
        Container(
            width: 48,
            height: 1,
            color: AppTheme.outlineVariant.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildScriptureContent() {
    if (_chapter == null || _chapter!.verses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: _chapter!.verses
          .map((verse) => Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: VerseWidget(
                  number: verse.number,
                  text: verse.text,
                  isHighlighted: false,
                  onVerseLongPress: _handleVerseLongPress,
                ),
              ))
          .toList(),
    );
  }

  /// Solo el separador "Amén" — la navegación es por scroll/overscroll
  Widget _buildChapterNav() {
    return Center(
      child: Column(
        children: [
          Container(
              width: 96,
              height: 1,
              color: AppTheme.secondary.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text('Amén',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.onSurface.withOpacity(0.4),
                    fontSize: 14,
                  )),
        ],
      ),
    );
  }
}

/// Indicador animado: check → flecha de siguiente capítulo
class _ChapterCompleteIndicator extends StatefulWidget {
  final bool ready;       // false = muestra check, true = muestra flecha
  final bool hasNext;
  final VoidCallback onNext;

  const _ChapterCompleteIndicator({
    required this.ready,
    required this.hasNext,
    required this.onNext,
  });

  @override
  State<_ChapterCompleteIndicator> createState() =>
      _ChapterCompleteIndicatorState();
}

class _ChapterCompleteIndicatorState extends State<_ChapterCompleteIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_ChapterCompleteIndicator old) {
    super.didUpdateWidget(old);
    if (widget.ready != old.ready) {
      // Pequeño rebote al transicionar de check a flecha
      _ctrl.forward(from: 0.6);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.ready && widget.hasNext
        ? Icons.keyboard_arrow_down_rounded
        : Icons.check_rounded;
    final color = AppTheme.secondary;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.ready && widget.hasNext ? widget.onNext : null,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingProgressIndicator extends StatelessWidget {
  final double progress;
  const _ReadingProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(children: [
          Container(
              width: 3,
              height: constraints.maxHeight,
              color: AppTheme.outlineVariant.withOpacity(0.12)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            width: 3,
            height: constraints.maxHeight * progress,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}
