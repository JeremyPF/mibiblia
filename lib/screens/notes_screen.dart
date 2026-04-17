import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/saved_verses_service.dart';
import '../theme/app_theme.dart';
import '../providers/reading_settings_provider.dart';

// ── NotesScreen ────────────────────────────────────────────────────────────

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await NotesService.getAll();
    if (mounted) setState(() => _notes = notes);
  }

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
        title: Text('Anotaciones',
            style: GoogleFonts.newsreader(
                fontSize: 20, fontStyle: FontStyle.italic)),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Text('No hay anotaciones todavía',
                  style: GoogleFonts.newsreader(
                      color: AppTheme.outline.withOpacity(0.5),
                      fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (_, i) => _NoteCard(
                note: _notes[i],
                onTap: () async {
                  await NoteEditorModal.show(context, note: _notes[i]);
                  _load();
                },
                onDelete: () async {
                  await NotesService.delete(_notes[i].id);
                  _load();
                },
              ),
            ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard(
      {required this.note, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bg = note.darkBackground
        ? const Color(0xFF1C1C1C)
        : Theme.of(context).colorScheme.surfaceContainerLow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppTheme.outlineVariant.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Referencia bíblica
              Text(
                '${note.bookName} ${note.chapterNumber}:${note.verseNumber}',
                style: GoogleFonts.newsreader(
                    fontSize: 11,
                    color: AppTheme.secondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Texto de la nota
              Text(
                note.noteText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.getFont(
                  note.fontFamily,
                  fontSize: 14,
                  height: 1.6,
                  color: Color(note.textColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _fmt(note.createdAt),
                style: GoogleFonts.newsreader(
                    fontSize: 10,
                    color: AppTheme.outline.withOpacity(0.5)),
              ),
            ]),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: AppTheme.outline.withOpacity(0.4)),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ── NoteEditorModal ────────────────────────────────────────────────────────

class NoteEditorModal extends StatefulWidget {
  final Note? note; // null = nueva nota sin versículo vinculado
  final String? bookName;
  final int? chapterNumber;
  final int? verseNumber;
  final String? verseText;

  const NoteEditorModal({
    super.key,
    this.note,
    this.bookName,
    this.chapterNumber,
    this.verseNumber,
    this.verseText,
  });

  static Future<Note?> show(BuildContext context,
      {Note? note,
      String? bookName,
      int? chapterNumber,
      int? verseNumber,
      String? verseText}) async {
    return showGeneralDialog<Note>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'note',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => NoteEditorModal(
        note: note,
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  State<NoteEditorModal> createState() => _NoteEditorModalState();
}

class _NoteEditorModalState extends State<NoteEditorModal> {
  late TextEditingController _ctrl;
  late String _fontFamily;
  late double _fontSize;
  late double _lineHeight;
  late bool _darkBg;
  late Color _textColor;
  bool _showFormat = false;

  static const _fonts = ReadingSettingsProvider.elegantFonts;
  static const _colors = [
    Color(0xFF2E342F), Color(0xFF1A237E), Color(0xFF4A148C),
    Color(0xFF880E4F), Color(0xFFDEE4DC), Color(0xFFF5F5F5),
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _ctrl        = TextEditingController(text: n?.noteText ?? '');
    _fontFamily  = n?.fontFamily  ?? 'Newsreader';
    _fontSize    = n?.fontSize    ?? 16.0;
    _lineHeight  = n?.lineHeight  ?? 1.8;
    _darkBg      = n?.darkBackground ?? false;
    _textColor   = Color(n?.textColor ?? 0xFF2E342F);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) { Navigator.of(context).pop(); return; }

    final existing = widget.note;
    final note = Note(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bookName:      existing?.bookName      ?? widget.bookName      ?? '',
      chapterNumber: existing?.chapterNumber ?? widget.chapterNumber ?? 0,
      verseNumber:   existing?.verseNumber   ?? widget.verseNumber   ?? 0,
      verseText:     existing?.verseText     ?? widget.verseText     ?? '',
      noteText: text,
      createdAt: existing?.createdAt ?? DateTime.now(),
      fontFamily: _fontFamily,
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      darkBackground: _darkBg,
      textColor: _textColor.value,
    );
    final saved = await NotesService.save(note);
    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _darkBg ? const Color(0xFF1C1C1C) : Theme.of(context).scaffoldBackgroundColor;

    return Stack(children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // Sube el modal cuando aparece el teclado
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88),
            decoration: BoxDecoration(
              color: bg.withOpacity(0.97),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                  blurRadius: 24, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Handle + header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 12, 0),
                  child: Column(children: [
                    Center(child: Container(width: 36, height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.outlineVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 12),
                    Row(children: [
                      // Referencia bíblica si existe
                      if ((widget.bookName ?? widget.note?.bookName ?? '').isNotEmpty)
                        Text(
                          '${widget.note?.bookName ?? widget.bookName} '
                          '${widget.note?.chapterNumber ?? widget.chapterNumber}'
                          ':${widget.note?.verseNumber ?? widget.verseNumber}',
                          style: GoogleFonts.newsreader(
                              fontSize: 11,
                              color: AppTheme.secondary,
                              letterSpacing: 1.2),
                        ),
                      const Spacer(),
                      // Toggle formato
                      IconButton(
                        icon: Icon(Icons.tune,
                            color: _showFormat
                                ? AppTheme.secondary
                                : AppTheme.outline.withOpacity(0.5),
                            size: 20),
                        onPressed: () => setState(() => _showFormat = !_showFormat),
                      ),
                      // Guardar
                      TextButton(
                        onPressed: _save,
                        child: Text('Guardar',
                            style: TextStyle(color: AppTheme.secondary)),
                      ),
                    ]),
                  ]),
                ),
                // Texto de la nota
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      autofocus: widget.note == null,
                      style: GoogleFonts.getFont(
                        _fontFamily,
                        fontSize: _fontSize,
                        height: _lineHeight,
                        color: _textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu reflexión...',
                        hintStyle: GoogleFonts.newsreader(
                            color: _textColor.withOpacity(0.3),
                            fontSize: _fontSize),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                // Panel de formato
                if (_showFormat) ...[
                  Divider(color: AppTheme.outlineVariant.withOpacity(0.15)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _buildSlider('TAMAÑO', _fontSize, 12, 28,
                          (v) => setState(() => _fontSize = v)),
                      _buildSlider('INTERLINEADO', _lineHeight, 1.2, 3.0,
                          (v) => setState(() => _lineHeight = v)),
                      const SizedBox(height: 8),
                      // Fondo claro/oscuro
                      Row(children: [
                        Text('FONDO', style: _labelStyle(context)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _darkBg = false),
                          child: _BgSwatch(
                              color: Colors.white, selected: !_darkBg),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _darkBg = true),
                          child: _BgSwatch(
                              color: const Color(0xFF1C1C1C),
                              selected: _darkBg),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      // Color de texto
                      Row(children: [
                        Text('COLOR', style: _labelStyle(context)),
                        const Spacer(),
                        ..._colors.map((c) => GestureDetector(
                              onTap: () => setState(() => _textColor = c),
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: _textColor.value == c.value
                                      ? Border.all(
                                          color: AppTheme.secondary, width: 2)
                                      : Border.all(
                                          color: AppTheme.outlineVariant
                                              .withOpacity(0.3)),
                                ),
                              ),
                            )),
                      ]),
                      const SizedBox(height: 8),
                      // Fuente
                      Row(children: [
                        Text('FUENTE', style: _labelStyle(context)),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _fontFamily,
                          underline: const SizedBox(),
                          isDense: true,
                          style: GoogleFonts.newsreader(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface),
                          items: _fonts.map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(f,
                                    style: GoogleFonts.getFont(f,
                                        fontSize: 13)),
                              )).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _fontFamily = v);
                          },
                        ),
                      ]),
                    ]),
                  ),
                ],
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(children: [
      SizedBox(width: 88,
          child: Text(label, style: _labelStyle(context))),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min, max: max,
          activeColor: AppTheme.secondary,
          inactiveColor: AppTheme.outlineVariant.withOpacity(0.3),
          onChanged: onChanged,
        ),
      ),
      SizedBox(width: 32,
          child: Text(value.toStringAsFixed(1),
              style: _labelStyle(context))),
    ]);
  }

  TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
          color: AppTheme.outline.withOpacity(0.7), letterSpacing: 1.5);
}

class _BgSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  const _BgSwatch({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) => Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? AppTheme.secondary
                : AppTheme.outlineVariant.withOpacity(0.4),
            width: selected ? 2 : 1,
          ),
        ),
      );
}
