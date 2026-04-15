import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bible_book.dart';
import 'reading_screen.dart';

class ChapterSelectorScreen extends StatefulWidget {
  final BibleBook book;

  const ChapterSelectorScreen({
    super.key,
    required this.book,
  });

  @override
  State<ChapterSelectorScreen> createState() => _ChapterSelectorScreenState();
}

class _ChapterSelectorScreenState extends State<ChapterSelectorScreen> {
  int selectedChapter = 1;
  bool isChapterView = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: const BoxDecoration(
          color: Color(0xFFFDFDF9),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildNumberGrid()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECCIONAR CAPÍTULO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.name,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 30,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.book.chapters,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = number == selectedChapter;

          return InkWell(
            onTap: () {
              setState(() {
                selectedChapter = number;
              });
            },
            onDoubleTap: () {
              _navigateToReading(number);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD2B48C).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    number.toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 24,
                          color: isSelected
                              ? AppTheme.onSurface
                              : AppTheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 8,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _navigateToReading(selectedChapter),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              'LEER CAPÍTULO $selectedChapter',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReading(int chapterNumber) {
    Navigator.pop(context); // Cerrar el diálogo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingScreen(
          bookId: widget.book.id,
          bookName: widget.book.name,
          chapterNumber: chapterNumber,
        ),
      ),
    );
  }
}
