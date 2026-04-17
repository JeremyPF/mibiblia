import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';

class ModoIAScreen extends StatefulWidget {
  const ModoIAScreen({super.key});
  @override
  State<ModoIAScreen> createState() => _ModoIAScreenState();
}

class _ModoIAScreenState extends State<ModoIAScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  _IAResult? _result;
  // Historial de consultas
  final List<_HistoryEntry> _history = [];

  static const _suggestions = [
    '¿Qué dice la Biblia sobre el perdón?',
    'Cuéntame la historia de David y Goliat',
    '¿Qué versículos hablan de la paz?',
    'Cuéntame la historia de la creación',
    '¿Qué dice Jesús sobre el amor?',
    'Cuéntame la historia de José y sus hermanos',
  ];

  Future<void> _ask(String query) async {
    if (query.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() { _loading = true; _result = null; });

    try {
      // Detect if it's a story request
      final isStory = _detectStory(query);

      final prompt = isStory
          ? '''El usuario pide: "$query"
Responde en JSON con este formato exacto:
{
  "mode": "story",
  "title": "Título de la historia",
  "verses": [{"ref": "Libro Cap:Vers", "text": "texto del versículo"}],
  "narrative": ["párrafo cinematográfico 1", "párrafo 2", "párrafo 3"],
  "reflection": "reflexión final breve"
}
Usa máximo 3 versículos clave. Los párrafos deben ser vívidos, presentes, cinematográficos.'''
          : '''El usuario pregunta: "$query"
Responde en JSON con este formato exacto:
{
  "mode": "text",
  "verses": [{"ref": "Libro Cap:Vers", "text": "texto del versículo"}],
  "explanation": "explicación clara y directa en 2-3 párrafos",
  "suggestions": ["pregunta relacionada 1", "pregunta relacionada 2", "pregunta relacionada 3"]
}
Usa máximo 3 versículos relevantes.''';

      final raw = await GroqService.ask(
        verseRef: '',
        verseText: '',
        userMessage: prompt,
        history: const [],
      );

      // Extract JSON from response
      final jsonStr = _extractJson(raw);
      if (jsonStr == null) throw Exception('No JSON in response');

      // Parse manually to avoid dart:convert issues with dynamic
      final result = _parseResult(jsonStr);
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
          _history.insert(0, _HistoryEntry(query: query, result: result));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; });
        showAppToast(context, 'No pude procesar la respuesta. Intenta de nuevo.',
            icon: Icons.error_outline);
      }
    }
  }

  bool _detectStory(String q) {
    final lower = q.toLowerCase();
    return lower.contains('historia') || lower.contains('cuéntame') ||
        lower.contains('cuentame') || lower.contains('relata') ||
        lower.contains('narra');
  }

  String? _extractJson(String raw) {
    // Strip markdown code fences if present
    var text = raw.replaceAll(RegExp(r'```json\s*'), '').replaceAll(RegExp(r'```\s*'), '');

    // Find the outermost JSON object by counting braces
    int start = -1;
    int depth = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '{') {
        if (start == -1) start = i;
        depth++;
      } else if (text[i] == '}') {
        depth--;
        if (depth == 0 && start != -1) {
          return text.substring(start, i + 1);
        }
      }
    }
    return null;
  }

  _IAResult _parseResult(String jsonStr) {
    // Sanitize: remove control characters that break JSON parsing
    final clean = jsonStr.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
    Map<String, dynamic> map;
    try {
      map = jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      // Fallback: treat entire response as explanation text
      return _IAResult.text(verses: [], explanation: clean, suggestions: []);
    }
    final mode = map['mode'] as String? ?? 'text';
    final versesList = (map['verses'] as List? ?? [])
        .map((v) => _Verse(
              ref: (v['ref'] ?? '').toString(),
              text: (v['text'] ?? '').toString(),
            ))
        .toList();

    if (mode == 'story') {
      return _IAResult.story(
        title: (map['title'] ?? '').toString(),
        verses: versesList,
        narrative: (map['narrative'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        reflection: (map['reflection'] ?? '').toString(),
      );
    } else {
      return _IAResult.text(
        verses: versesList,
        explanation: (map['explanation'] ?? '').toString(),
        suggestions: (map['suggestions'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.outlineVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text('Historial', style: GoogleFonts.newsreader(
                fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(
                  _history[i].result.isStory
                      ? Icons.auto_stories_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: AppTheme.secondary, size: 18),
                title: Text(_history[i].query,
                    style: GoogleFonts.newsreader(fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _result = _history[i].result);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondary, size: 18),
          const SizedBox(width: 8),
          Text('Modo IA', style: GoogleFonts.newsreader(
              fontSize: 18, fontStyle: FontStyle.italic)),
        ]),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history_rounded, color: AppTheme.secondary),
              tooltip: 'Historial',
              onPressed: _showHistory,
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
              : _result == null
                  ? _buildEmpty()
                  : _result!.isStory
                      ? _StoryView(result: _result!)
                      : _TextView(result: _result!, onSuggestion: _ask),
        ),
        _buildInput(),
      ]),
    );
  }

  Widget _buildEmpty() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 24),
        Text('✨', style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Pregúntame sobre la Biblia',
            style: GoogleFonts.notoSerif(
                fontSize: 22, fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text('Puedo explicar textos o contarte historias bíblicas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
                fontSize: 14, color: AppTheme.outline, height: 1.5)),
        const SizedBox(height: 32),
        Wrap(spacing: 8, runSpacing: 8, children: _suggestions.map((s) =>
          GestureDetector(
            onTap: () => _ask(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondary.withOpacity(0.25)),
              ),
              child: Text(s, style: GoogleFonts.newsreader(
                  fontSize: 13, color: AppTheme.secondary)),
            ),
          ),
        ).toList()),
      ]),
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: GoogleFonts.newsreader(fontSize: 15),
                textInputAction: TextInputAction.send,
                onSubmitted: _ask,
                decoration: InputDecoration(
                  hintText: 'Pregunta o pide una historia...',
                  hintStyle: GoogleFonts.newsreader(
                      fontSize: 14, color: AppTheme.outline.withOpacity(0.4)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: AppTheme.outlineVariant.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppTheme.secondary)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _ask(_ctrl.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                    color: AppTheme.secondary, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Text Mode View ─────────────────────────────────────────────────────────

class _TextView extends StatelessWidget {
  final _IAResult result;
  final Function(String) onSuggestion;
  const _TextView({required this.result, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Versículos
        if (result.verses.isNotEmpty) ...[
          Text('VERSÍCULOS', style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppTheme.secondary, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...result.verses.map((v) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border(left: BorderSide(color: AppTheme.secondary, width: 3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.ref, style: GoogleFonts.newsreader(
                  fontSize: 11, color: AppTheme.secondary,
                  letterSpacing: 1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('«${v.text}»', style: GoogleFonts.newsreader(
                  fontSize: 15, height: 1.6, fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85))),
            ]),
          )),
          const SizedBox(height: 20),
        ],
        // Explicación
        Row(children: [
          Text('EXPLICACIÓN', style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppTheme.secondary, letterSpacing: 2)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 16, color: AppTheme.secondary),
            tooltip: 'Copiar',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.explanation));
              showAppToast(context, 'Copiado', icon: Icons.content_copy);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 16, color: AppTheme.secondary),
            tooltip: 'Compartir',
            onPressed: () => Share.share(result.explanation),
          ),
        ]),
        const SizedBox(height: 12),
        Text(result.explanation, style: GoogleFonts.newsreader(
            fontSize: 15, height: 1.75,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85))),
        // Sugerencias
        if (result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('EXPLORAR MÁS', style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppTheme.secondary, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...result.suggestions.map((s) => GestureDetector(
            onTap: () => onSuggestion(s),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
              ),
              child: Row(children: [
                Expanded(child: Text(s, style: GoogleFonts.newsreader(
                    fontSize: 14, color: Theme.of(context).colorScheme.onSurface))),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppTheme.secondary),
              ]),
            ),
          )),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ── Story Mode View ────────────────────────────────────────────────────────

class _StoryView extends StatefulWidget {
  final _IAResult result;
  const _StoryView({required this.result});
  @override
  State<_StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<_StoryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  int _visibleParagraph = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    // Reveal paragraphs one by one
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (_visibleParagraph < widget.result.narrative.length - 1) {
        setState(() => _visibleParagraph++);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return FadeTransition(
      opacity: _fade,
      child: SingleChildScrollView(
        child: Column(children: [
          // Hero header — estética del onboarding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E342F), Color(0xFF3D2E1A), Color(0xFF735B3A)],
              ),
            ),
            child: Column(children: [
              Text('📖', style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(r.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                      fontSize: 28, fontWeight: FontWeight.w300,
                      color: Colors.white, letterSpacing: 0.5)),
              if (r.verses.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(r.verses.first.ref,
                    style: GoogleFonts.newsreader(
                        fontSize: 12, color: Colors.white60, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('«${r.verses.first.text}»',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.newsreader(
                        fontSize: 15, height: 1.7,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.85))),
              ],
            ]),
          ),
          // Narrative paragraphs — revealed one by one
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...List.generate(
                (_visibleParagraph + 1).clamp(0, r.narrative.length),
                (i) => _NarrativeParagraph(
                  text: r.narrative[i],
                  animate: i == _visibleParagraph,
                ),
              ),
              // Additional verses
              if (r.verses.length > 1) ...[
                const SizedBox(height: 24),
                ...r.verses.skip(1).map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF735B3A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(
                        color: const Color(0xFF735B3A), width: 3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.ref, style: GoogleFonts.newsreader(
                        fontSize: 11, color: const Color(0xFF735B3A),
                        letterSpacing: 1, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('«${v.text}»', style: GoogleFonts.newsreader(
                        fontSize: 14, height: 1.6, fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                  ]),
                )),
              ],
              // Reflection
              if (r.reflection.isNotEmpty &&
                  _visibleParagraph >= r.narrative.length - 1) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('REFLEXIÓN', style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppTheme.secondary, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(r.reflection, style: GoogleFonts.newsreader(
                        fontSize: 15, height: 1.7,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85))),
                  ]),
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NarrativeParagraph extends StatefulWidget {
  final String text;
  final bool animate;
  const _NarrativeParagraph({required this.text, required this.animate});
  @override
  State<_NarrativeParagraph> createState() => _NarrativeParagraphState();
}

class _NarrativeParagraphState extends State<_NarrativeParagraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) _ctrl.forward();
    else _ctrl.value = 1.0;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(widget.text, style: GoogleFonts.newsreader(
            fontSize: 16, height: 1.85,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.88))),
      ),
    ),
  );
}

// ── Data models ────────────────────────────────────────────────────────────

class _Verse {
  final String ref, text;
  const _Verse({required this.ref, required this.text});
}

class _HistoryEntry {
  final String query;
  final _IAResult result;
  const _HistoryEntry({required this.query, required this.result});
}

class _IAResult {
  final bool isStory;
  final String title;
  final List<_Verse> verses;
  final String explanation;
  final List<String> suggestions;
  final List<String> narrative;
  final String reflection;

  const _IAResult._({
    required this.isStory,
    this.title = '',
    required this.verses,
    this.explanation = '',
    this.suggestions = const [],
    this.narrative = const [],
    this.reflection = '',
  });

  factory _IAResult.text({
    required List<_Verse> verses,
    required String explanation,
    required List<String> suggestions,
  }) => _IAResult._(isStory: false, verses: verses,
      explanation: explanation, suggestions: suggestions);

  factory _IAResult.story({
    required String title,
    required List<_Verse> verses,
    required List<String> narrative,
    required String reflection,
  }) => _IAResult._(isStory: true, title: title, verses: verses,
      narrative: narrative, reflection: reflection);
}
