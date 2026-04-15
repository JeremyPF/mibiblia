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
  double _appBarOpacity = 0.6;
  int? _selectedVerseNumber;
  String? _selectedVerseText;
  final List<Highlight> _highlights = [];
  final List<Note> _notes = [];

  Chapter? _chapter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapter();
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
      } else {
        _selectedVerseNumber = verseNumber;
        _selectedVerseText = verseText;
      }
    });
  }

  void _handleSaveVerse(int verseNumber, String verseText) {
    final highlight = Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookName: widget.bookName,
      chapterNumber: widget.chapterNumber,
      verseNumber: verseNumber,
      verseText: verseText,
      createdAt: DateTime.now(),
    );
    setState(() {
      _highlights.add(highlight);
      _selectedVerseNumber = null;
      _selectedVerseText = null;
    });
  }

  void _handleAddNote(int verseNumber, String verseText) async {
    final noteText = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        verseNumber: verseNumber,
        verseText: verseText,
      ),
    );

    if (noteText != null && noteText.isNotEmpty) {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookName: widget.bookName,
        chapterNumber: widget.chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        noteText: noteText,
        createdAt: DateTime.now(),
      );
      setState(() {
        _notes.add(note);
        _selectedVerseNumber = null;
        _selectedVerseText = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota guardada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleCloseActionBar() {
    setState(() {
      _selectedVerseNumber = null;
      _selectedVerseText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: _selectedVerseNumber != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: VerseActionBar(
                bookName: widget.bookName,
                chapterNumber: widget.chapterNumber,
                verseNumber: _selectedVerseNumber!,
                verseText: _selectedVerseText!,
                onClose: _handleCloseActionBar,
                onSave: _handleSaveVerse,
                onAddNote: _handleAddNote,
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: TopAppBar(opacity: _appBarOpacity),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapter == null
              ? _buildErrorView()
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    setState(() {
                      _appBarOpacity =
                          scrollNotification.metrics.pixels > 100 ? 1.0 : 0.6;
                    });
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
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
            const Icon(Icons.error_outline, size: 64, color: AppTheme.secondary),
            const SizedBox(height: 24),
            Text(
              'No se pudo cargar el capítulo',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'El capítulo ${widget.chapterNumber} de ${widget.bookName} no está disponible.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.onSecondary,
              ),
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
            color: AppTheme.secondary.withOpacity(0.2),
          ),
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
