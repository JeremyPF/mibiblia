import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChapterSelectorScreen extends StatefulWidget {
  final String bookName;
  final int totalChapters;

  const ChapterSelectorScreen({
    super.key,
    required this.bookName,
    required this.totalChapters,
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
                      'NAVIGATE TO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.bookName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 30,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildTabButton('CHAPTER', true),
                  const SizedBox(width: 32),
                  _buildTabButton('VERSE', false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          isChapterView = isActive;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.secondary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive
                    ? AppTheme.secondary
                    : AppTheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
        ),
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
        itemCount: widget.totalChapters,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = number == selectedChapter;

          return InkWell(
            onTap: () {
              setState(() {
                selectedChapter = number;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD2B48C).withOpacity(0.2)
                    : Colors.transparent,
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
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: AppTheme.onSurface,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'PREVIOUS BOOK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurface.withOpacity(0.4),
                      ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  'NEXT BOOK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurface.withOpacity(0.4),
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.onSurface,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
