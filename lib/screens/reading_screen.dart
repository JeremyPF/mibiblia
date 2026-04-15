import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/verse_widget.dart';
import '../widgets/side_drawer.dart';
import '../widgets/verse_action_bar.dart';
import '../widgets/note_dialog.dart';
import '../theme/app_theme.dart';
import '../models/highlight.dart';
import '../models/note.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  double _appBarOpacity = 0.6;
  int? _selectedVerseNumber;
  String? _selectedVerseText;
  final List<Highlight> _highlights = [];
  final List<Note> _notes = [];

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
      bookName: 'SALMOS',
      chapterNumber: 23,
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
        bookName: 'SALMOS',
        chapterNumber: 23,
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
                bookName: 'SALMOS',
                chapterNumber: 23,
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          setState(() {
            _appBarOpacity = scrollNotification.metrics.pixels > 100 ? 1.0 : 0.6;
          });
          return true;
        },
        child: SingleChildScrollView(
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SALMOS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          '23',
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
    final verses = [
      'O Senhor é o meu pastor; nada me faltará.',
      'Deitar-me faz em verdes pastos, guia-me mansamente a águas tranquilas.',
      'Refrigera a minha alma; guia-me pelas veredas da justiça por amor do seu nome.',
      'Ainda que eu andasse pelo vale da sombra da morte, não temeria mal algum, porque tu estás comigo; a tua vara e o teu cajado me consolam.',
      'Preparas uma mesa perante mim na presença dos meus inimigos, unges a minha cabeça com óleo, o meu cálice transborda.',
      'Certamente que a bondade e a misericórdia me seguirão todos os dias da minha vida; e habitarei na Casa do Senhor por longos dias.',
    ];

    return Column(
      children: List.generate(
        verses.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: VerseWidget(
            number: index + 1,
            text: verses[index],
            isHighlighted: index == 3,
            onVerseLongPress: _handleVerseLongPress,
          ),
        ),
      ),
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
            'Amém',
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
