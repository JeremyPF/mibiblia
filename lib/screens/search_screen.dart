import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/bible_service.dart';
import 'reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchResult> _results = [];
  bool _indexReady = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _initIndex();
    // Abrir teclado automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  Future<void> _initIndex() async {
    if (!BibleService.isIndexReady) {
      await BibleService.buildSearchIndex();
    }
    if (mounted) setState(() => _indexReady = true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() { _results = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 150), () {
      final results = BibleService.search(query);
      if (mounted) setState(() { _results = results; _searching = false; });
    });
  }

  void _openVerse(SearchResult r) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          bookId: r.bookId,
          bookName: r.bookName,
          chapterNumber: r.chapterNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      style: GoogleFonts.newsreader(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Buscar en la Biblia...',
                        hintStyle: GoogleFonts.newsreader(
                          fontSize: 18,
                          color: AppTheme.outline.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18,
                                    color: AppTheme.outline),
                                onPressed: () {
                                  _controller.clear();
                                  _onQueryChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.2), height: 1),
            // Estado del índice
            if (!_indexReady)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppTheme.secondary),
                      SizedBox(height: 16),
                      Text('Preparando búsqueda...'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _buildResults(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final query = _controller.text.trim();

    if (query.length < 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48,
                color: AppTheme.outlineVariant.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Escribe para buscar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.outline.withOpacity(0.6),
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      );
    }

    if (_searching) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.secondary));
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Sin resultados para "$query"',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.outline.withOpacity(0.6),
                fontSize: 16,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            '${_results.length} resultado${_results.length != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.secondary,
                  letterSpacing: 2.0,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, i) => _SearchResultTile(
              result: _results[i],
              query: query,
              onTap: () => _openVerse(_results[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referencia
            Text(
              '${result.bookName}  ${result.chapterNumber}:${result.verseNumber}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.secondary,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 6),
            // Texto con highlight de la búsqueda
            _HighlightedText(text: result.verseText, query: query),
            Divider(
              color: AppTheme.outlineVariant.withOpacity(0.15),
              height: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// Resalta las coincidencias de la búsqueda en el texto del versículo
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.newsreader(
      fontSize: 15,
      color: AppTheme.onSurface.withOpacity(0.8),
      height: 1.6,
    );
    final highlightStyle = baseStyle.copyWith(
      backgroundColor: AppTheme.secondary.withOpacity(0.2),
      color: AppTheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    // Normalizar para encontrar coincidencias sin importar acentos
    final normalizedText = _normalize(text);
    final normalizedQuery = _normalize(query.split(' ').first);
    if (normalizedQuery.length < 2) return Text(text, style: baseStyle);

    final spans = <TextSpan>[];
    int start = 0;
    final pattern = RegExp(RegExp.escape(normalizedQuery), caseSensitive: false);

    for (final match in pattern.allMatches(normalizedText)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: baseStyle));
      }
      spans.add(TextSpan(text: text.substring(match.start, match.end), style: highlightStyle));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _normalize(String t) => t
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n');
}
