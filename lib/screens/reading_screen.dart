import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/verse_widget.dart';
import '../widgets/side_drawer.dart';
import '../widgets/verse_action_bar.dart';
import '../theme/app_theme.dart';
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
  // Lista de capítulos cargados para scroll continuo
  final List<Chapter> _loadedChapters = [];
  final List<int> _loadedChapterNumbers = [];
  bool _isLoading = true;
  bool _chapterMarkedRead = false;
  // Set de capítulos ya marcados como leídos en esta sesión
  final Set<int> _readInSession = {};
  // Mostrar check badge pequeño a la derecha
  bool _showReadBadge = false;

  int? _selectedVerseNumber;
  String? _selectedVerseText;
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
    _loadChapter(_currentChapter);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  // Navegación por scroll al final
  Timer? _navDebounce;
  bool _loadingChapter = false;
  bool _loadingNextChapter = false;

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

    if (_loadingChapter || _loadingNextChapter) return;

    // Cargar siguiente capítulo al llegar al 90% del scroll
    if (_hasNextChapter && maxScroll > 0 && current >= maxScroll * 0.9) {
      final nextCap = _loadedChapterNumbers.last + 1;
      if (!_loadedChapterNumbers.contains(nextCap)) {
        _appendNextChapter(nextCap);
      }
    }
  }

  // Estado del indicador de capítulo completado
  bool _showCompleteIndicator = false;
  bool _indicatorReady = false;

  Future<void> _markCurrentChapterRead() async {
    if (_chapterMarkedRead) return;
    _chapterMarkedRead = true;
    await ReadingProgressService.markChapterRead(widget.bookId, _currentChapter);
    if (!mounted) return;
    // Check pequeño a la derecha — aparece y desaparece en 2s
    setState(() => _showReadBadge = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showReadBadge = false);
    });
  }

  Future<void> _loadChapter(int chapterNum) async {
    setState(() => _isLoading = true);
    final chapter = await BibleService.loadChapter(widget.bookId, chapterNum);
    if (!mounted) return;
    if (chapter != null) {
      _loadedChapters.add(chapter);
      _loadedChapterNumbers.add(chapterNum);
    }
    setState(() { _isLoading = false; _chapterMarkedRead = false; });
    UserProfileService.saveLastPosition(widget.bookId, widget.bookName, chapterNum);
  }

  Future<void> _appendNextChapter(int chapterNum) async {
    if (_loadingNextChapter) return;
    _loadingNextChapter = true;
    final chapter = await BibleService.loadChapter(widget.bookId, chapterNum);
    if (!mounted) { _loadingNextChapter = false; return; }
    if (chapter != null) {
      setState(() {
        _loadedChapters.add(chapter);
        _loadedChapterNumbers.add(chapterNum);
        _currentChapter = chapterNum;
        _chapterMarkedRead = false;
      });
      UserProfileService.saveLastPosition(widget.bookId, widget.bookName, chapterNum);
    }
    _loadingNextChapter = false;
  }

  bool get _hasNextChapter {
    final lastLoaded = _loadedChapterNumbers.isEmpty ? _currentChapter : _loadedChapterNumbers.last;
    return BibleService.isBookAvailable(widget.bookId) &&
        lastLoaded < _totalChaptersInBook;
  }

  bool get _hasPrevChapter => _currentChapter > 1;

  void _goToNextChapter() {}  // no longer used
  void _goToPrevChapter() {}  // no longer used

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
          : Stack(
              children: [
                // Scroll continuo de todos los capítulos cargados
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 100),
                            for (int i = 0; i < _loadedChapters.length; i++) ...[
                              _buildChapterBlock(_loadedChapterNumbers[i], _loadedChapters[i]),
                              if (i < _loadedChapters.length - 1)
                                _buildChapterDivider(),
                            ],
                            if (_loadingNextChapter)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Indicador de progreso lateral
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: _ReadingProgressIndicator(progress: _scrollProgress),
                ),
                // Check badge pequeño a la derecha — aparece y desaparece
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  right: _showReadBadge ? 12 : -40,
                  bottom: 80,
                  child: AnimatedOpacity(
                    opacity: _showReadBadge ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondary.withOpacity(0.15),
                        border: Border.all(
                            color: AppTheme.secondary.withOpacity(0.4), width: 1),
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 14, color: AppTheme.secondary),
                    ),
                  ),
                ),
                // VerseActionBar — bottom, solo visible con selección
                if (hasSelection)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: AnimatedSlide(
                      offset: Offset.zero,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: VerseActionBar(
                        bookName: widget.bookName,
                        chapterNumber: _currentChapter,
                        verseNumber: _selectedVerseNumber!,
                        verseText: _selectedVerseText!,
                        onClose: () => setState(() {
                          _selectedVerseNumber = null;
                          _selectedVerseText = null;
                        }),
                        onRefresh: () => setState(() {}),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildChapterBlock(int chapterNum, Chapter chapter) {
    final title = _chapterTitles[widget.bookId]?[chapterNum];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.bookName.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppTheme.secondary)),
        const SizedBox(height: 16),
        Text(chapterNum.toString(),
            style: Theme.of(context).textTheme.displayLarge),
        if (title != null) ...[
          const SizedBox(height: 12),
          Text(title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 18, fontStyle: FontStyle.italic,
                    color: AppTheme.outline, fontWeight: FontWeight.w300)),
        ],
        const SizedBox(height: 32),
        Container(width: 48, height: 1,
            color: AppTheme.outlineVariant.withOpacity(0.3)),
        const SizedBox(height: 80),
        ...chapter.verses.map((verse) => Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: VerseWidget(
                number: verse.number,
                text: verse.text,
                isHighlighted: false,
                bookName: widget.bookName,
                chapterNumber: chapterNum,
                onVerseLongPress: _handleVerseLongPress,
              ),
            )),
        const SizedBox(height: 40),
        Center(
          child: Column(children: [
            Container(width: 96, height: 1,
                color: AppTheme.secondary.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text('Amén',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.onSurface.withOpacity(0.4),
                      fontSize: 14)),
          ]),
        ),
      ],
    );
  }

  Widget _buildChapterDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(children: [
        Expanded(child: Divider(
            color: AppTheme.outlineVariant.withOpacity(0.15))),
      ]),
    );
  },
    );
  }

  Widget _buildScriptureContent() {
    if (_chapter == null || _chapter!.verses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: _chapter!.verses
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
