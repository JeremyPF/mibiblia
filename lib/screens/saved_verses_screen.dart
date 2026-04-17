import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/highlight.dart';
import '../services/saved_verses_service.dart';
import '../theme/app_theme.dart';

class SavedVersesScreen extends StatefulWidget {
  const SavedVersesScreen({super.key});

  @override
  State<SavedVersesScreen> createState() => _SavedVersesScreenState();
}

class _SavedVersesScreenState extends State<SavedVersesScreen> {
  List<Highlight> _all = [];
  List<VerseCategory> _categories = [];
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all  = await SavedVersesService.getAll();
    final cats = await SavedVersesService.getCategories();
    if (mounted) setState(() { _all = all; _categories = cats; });
  }

  List<Highlight> get _filtered => _filterCategory == null
      ? _all
      : _all.where((h) => h.category == _filterCategory).toList();

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
        title: Text('Guardados',
            style: GoogleFonts.newsreader(
                fontSize: 20, fontStyle: FontStyle.italic)),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined, color: AppTheme.secondary),
            tooltip: 'Gestionar categorías',
            onPressed: () async {
              await _showCategoryManager(context);
              _load();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro de categorías
          if (_categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos',
                    color: AppTheme.secondary,
                    selected: _filterCategory == null,
                    onTap: () => setState(() => _filterCategory = null),
                  ),
                  ..._categories.map((c) => _FilterChip(
                        label: c.name,
                        color: Color(c.color),
                        selected: _filterCategory == c.name,
                        onTap: () => setState(() => _filterCategory = c.name),
                      )),
                ],
              ),
            ),
          Divider(color: AppTheme.outlineVariant.withOpacity(0.15), height: 1),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No hay versículos guardados',
                        style: GoogleFonts.newsreader(
                            color: AppTheme.outline.withOpacity(0.5),
                            fontSize: 16)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _HighlightCard(
                      highlight: _filtered[i],
                      onDelete: () async {
                        await SavedVersesService.delete(_filtered[i].id);
                        _load();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryManager(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'cats',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => _CategoryManagerSheet(
        categories: _categories,
        onChanged: (cats) async {
          await SavedVersesService.saveCategories(cats);
          _load();
        },
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.color,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : color.withOpacity(0.3), width: 1),
        ),
        child: Text(label,
            style: GoogleFonts.newsreader(
                fontSize: 13,
                color: selected ? color : color.withOpacity(0.6),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400),
            textAlign: TextAlign.center),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final Highlight highlight;
  final VoidCallback onDelete;

  const _HighlightCard({required this.highlight, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = Color(highlight.color);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${highlight.bookName} ${highlight.chapterNumber}:${highlight.verseNumber}',
                    style: GoogleFonts.newsreader(
                        fontSize: 11,
                        color: color,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(highlight.verseText,
                      style: GoogleFonts.newsreader(
                          fontSize: 15,
                          height: 1.6,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.85))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(highlight.category,
                        style: GoogleFonts.newsreader(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: AppTheme.outline.withOpacity(0.4)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Manager Sheet ─────────────────────────────────────────────────

class _CategoryManagerSheet extends StatefulWidget {
  final List<VerseCategory> categories;
  final Function(List<VerseCategory>) onChanged;

  const _CategoryManagerSheet(
      {required this.categories, required this.onChanged});

  @override
  State<_CategoryManagerSheet> createState() => _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends State<_CategoryManagerSheet> {
  late List<VerseCategory> _cats;
  final _nameCtrl = TextEditingController();
  Color _pickedColor = const Color(0xFFFFD54F);

  static const _palette = [
    Color(0xFFFFD54F), Color(0xFF81C784), Color(0xFF64B5F6),
    Color(0xFFBA68C8), Color(0xFFFF8A65), Color(0xFF4DB6AC),
    Color(0xFFE57373), Color(0xFFA1887F),
  ];

  @override
  void initState() {
    super.initState();
    _cats = List.from(widget.categories);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Categorías', style: GoogleFonts.newsreader(
                    fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                // Lista de categorías existentes
                ..._cats.map((c) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                          radius: 8, backgroundColor: Color(c.color)),
                      title: Text(c.name,
                          style: GoogleFonts.newsreader(fontSize: 15)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          setState(() => _cats.remove(c));
                          widget.onChanged(_cats);
                        },
                      ),
                    )),
                const Divider(),
                // Nueva categoría
                Text('Nueva categoría',
                    style: GoogleFonts.newsreader(
                        fontSize: 12,
                        color: AppTheme.outline,
                        letterSpacing: 1)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.newsreader(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Nombre...',
                        hintStyle: GoogleFonts.newsreader(
                            color: AppTheme.outline.withOpacity(0.4)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_nameCtrl.text.trim().isEmpty) return;
                      final newCat = VerseCategory(
                          name: _nameCtrl.text.trim(),
                          color: _pickedColor.value);
                      setState(() { _cats.add(newCat); _nameCtrl.clear(); });
                      widget.onChanged(_cats);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                // Paleta de colores
                Wrap(
                  spacing: 8,
                  children: _palette.map((c) => GestureDetector(
                        onTap: () => setState(() => _pickedColor = c),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: _pickedColor == c
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    width: 2)
                                : null,
                          ),
                        ),
                      )).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
