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

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  double _appBarOpacity = 0.0;
  bool _showSubtitle = false;

  int? _selectedVerseNumber;
  String? _selectedVerseText;
  final List<Highlight> _highlights = [];
  final List<Note> _notes = [];

  Chapter? _chapter;
  bool _isLoading = true;

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
    _loadChapter();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final current = pos.pixels;
    final maxScroll = pos.maxScrollExtent;
    setState(() {
      _scrollProgress = maxScroll > 0 ? (current / maxScroll).clamp(0.0, 1.0) : 0.0;
      _appBarOpacity = (current / 120).clamp(0.0, 1.0);
      _showSubtitle = current > 200;
    });
  }

  Future<void> _loadChapter() async {
    final chapter = await BibleService.loadChapter(widget.bookId, widget.chapterNumber);
    setState(() { _chapter = chapter; _isLoading = false; });
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
        chapterNumber: widget.chapterNumber,
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
      builder: (context) => NoteDialog(verseNumber: verseNumber, verseText: verseText),
    );
    if (noteText != null && noteText.isNotEmpty) {
      setState(() {
        _notes.add(Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookName: widget.bookName,
          chapterNumber: widget.chapterNumber,
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
          const SnackBar(content: Text('Nota guardada'), duration: Duration(seconds: 2)),
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
      // AppBar siempre es TopAppBar — nunca cambia
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          opacity: _appBarOpacity.clamp(0.6, 1.0),
          bookName: widget.bookName,
          chapterNumber: widget.chapterNumber,
          showSubtitle: _showSubtitle,
          onSearchTap: widget.onSearchTap,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapter == null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Contenido de lectura
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 100),
                                _buildHeader(),
                                const SizedBox(height: 80),
                                _buildScriptureContent(),
                                const SizedBox(height: 128),
                                _buildFooter(),
                                const SizedBox(height: 160),
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
                    // VerseActionBar como overlay animado en la parte superior
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: AnimatedSlide(
                        offset: hasSelection ? Offset.zero : const Offset(0, -1),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: hasSelection ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: hasSelection
                              ? VerseActionBar(
                                  bookName: widget.bookName,
                                  chapterNumber: widget.chapterNumber,
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
    final title = _chapterTitles[widget.bookId]?[widget.chapterNumber];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.bookName.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppTheme.secondary)),
        const SizedBox(height: 16),
        Text(widget.chapterNumber.toString(),
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
        Container(width: 48, height: 1,
            color: AppTheme.outlineVariant.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildScriptureContent() {
    if (_chapter == null || _chapter!.verses.isEmpty) return const SizedBox.shrink();
    return Column(
      children: _chapter!.verses.map((verse) => Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: VerseWidget(
          number: verse.number,
          text: verse.text,
          isHighlighted: false,
          onVerseLongPress: _handleVerseLongPress,
        ),
      )).toList(),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(width: 96, height: 1, color: AppTheme.secondary.withOpacity(0.2)),
          const SizedBox(height: 32),
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

class _ReadingProgressIndicator extends StatelessWidget {
  final double progress;
  const _ReadingProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(children: [
          Container(width: 3, height: constraints.maxHeight,
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
