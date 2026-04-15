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

  const ReadingScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  double _appBarOpacity = 0.0;
  bool _showSubtitle = false;
  bool _showActionBar = false;

  int? _selectedVerseNumber;
  String? _selectedVerseText;
  final List<Highlight> _highlights = [];
  final List<Note> _notes = [];

  Chapter? _chapter;
  bool _isLoading = true;

  // Títulos de capítulo por libro (los que tenemos disponibles)
  static const Map<int, Map<int, String>> _chapterTitles = {
    20: { // Proverbios
      1: 'El comienzo de la sabiduría',
      2: 'Los beneficios de la sabiduría',
      3: 'Confía en el Señor',
      4: 'La senda de los justos',
      5: 'Advertencia contra la inmoralidad',
      6: 'Seis cosas que Dios aborrece',
      7: 'Advertencia contra la adultera',
      8: 'El llamado de la sabiduría',
      9: 'La sabiduría y la necedad',
      10: 'Proverbios de Salomón',
    },
    40: { // Mateo
      1: 'La genealogía de Jesucristo',
      2: 'La visita de los magos',
      3: 'Juan el Bautista',
      4: 'La tentación de Jesús',
      5: 'El Sermón del Monte',
      6: 'La oración del Señor',
      7: 'El árbol y sus frutos',
      8: 'Jesús sana a muchos',
      9: 'La fe que sana',
      10: 'Los doce apóstoles',
    },
    43: { // Juan
      1: 'El Verbo se hizo carne',
      2: 'Las bodas de Caná',
      3: 'El nuevo nacimiento',
      4: 'La mujer samaritana',
      5: 'La curación en el estanque',
      6: 'El pan de vida',
      7: 'Jesús en la fiesta',
      8: 'La mujer adúltera',
      9: 'El ciego de nacimiento',
      10: 'El buen pastor',
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
    final maxScroll = pos.maxScrollExtent;
    final current = pos.pixels;

    setState(() {
      _scrollProgress = maxScroll > 0 ? (current / maxScroll).clamp(0.0, 1.0) : 0.0;
      _appBarOpacity = (current / 120).clamp(0.0, 1.0);
      _showSubtitle = current > 200;
    });
  }

  Future<void> _loadChapter() async {
    final chapter = await BibleService.loadChapter(
      widget.bookId,
      widget.chapterNumber,
    );
    setState(() {
      _chapter = chapter;
      _isLoading = false;
    });
  }

  void _handleVerseLongPress(int verseNumber, String verseText) {
    setState(() {
      if (_selectedVerseNumber == verseNumber) {
        _selectedVerseNumber = null;
        _selectedVerseText = null;
        _showActionBar = false;
      } else {
        _selectedVerseNumber = verseNumber;
        _selectedVerseText = verseText;
        _showActionBar = true;
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
      _showActionBar = false;
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
          chapterNumber: widget.chapterNumber,
          verseNumber: verseNumber,
          verseText: verseText,
          noteText: noteText,
          createdAt: DateTime.now(),
        ));
        _selectedVerseNumber = null;
        _selectedVerseText = null;
        _showActionBar = false;
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

  void _handleCloseActionBar() {
    setState(() {
      _selectedVerseNumber = null;
      _selectedVerseText = null;
      _showActionBar = false;
    });
  }

  String? get _chapterTitle {
    return _chapterTitles[widget.bookId]?[widget.chapterNumber];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showSubtitle ? 64 : 56),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _showActionBar && _selectedVerseNumber != null
              ? VerseActionBar(
                  key: const ValueKey('action'),
                  bookName: widget.bookName,
                  chapterNumber: widget.chapterNumber,
                  verseNumber: _selectedVerseNumber!,
                  verseText: _selectedVerseText!,
                  onClose: _handleCloseActionBar,
                  onSave: _handleSaveVerse,
                  onAddNote: _handleAddNote,
                )
              : TopAppBar(
                  key: const ValueKey('top'),
                  opacity: _appBarOpacity.clamp(0.6, 1.0),
                  bookName: widget.bookName,
                  chapterNumber: widget.chapterNumber,
                  showSubtitle: _showSubtitle,
                ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapter == null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Contenido principal
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 800),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 128),
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
                    // Indicador de progreso lateral derecho
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _ReadingProgressIndicator(
                          progress: _scrollProgress),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppTheme.secondary),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.bookName.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppTheme.secondary),
        ),
        const SizedBox(height: 16),
        Text(
          widget.chapterNumber.toString(),
          style: Theme.of(context).textTheme.displayLarge,
        ),
        if (_chapterTitle != null) ...[
          const SizedBox(height: 12),
          Text(
            _chapterTitle!,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.outline,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ],
        const SizedBox(height: 32),
        Container(
          width: 48,
          height: 1,
          color: AppTheme.outlineVariant.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildScriptureContent() {
    if (_chapter == null || _chapter!.verses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: _chapter!.verses.map((verse) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: VerseWidget(
            number: verse.number,
            text: verse.text,
            isHighlighted: false,
            onVerseLongPress: _handleVerseLongPress,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
              width: 96,
              height: 1,
              color: AppTheme.secondary.withOpacity(0.2)),
          const SizedBox(height: 32),
          Text(
            'Amén',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de progreso de lectura — barra delgada en el borde derecho
class _ReadingProgressIndicator extends StatelessWidget {
  final double progress;

  const _ReadingProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Track
              Container(
                width: 3,
                height: constraints.maxHeight,
                color: AppTheme.outlineVariant.withOpacity(0.12),
              ),
              // Fill animado
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
            ],
          );
        },
      ),
    );
  }
}
