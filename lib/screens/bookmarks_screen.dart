import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_drawer.dart';
import '../models/bookmark.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.full(80),
        child: TopAppBar(opacity: 0.85),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 96),
                _buildSearchSection(context),
                const SizedBox(height: 48),
                _buildBookmarksSection(context),
                const SizedBox(height: 80),
                _buildDecorativeFooter(context),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH THE WORD',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
              ),
          decoration: InputDecoration(
            hintText: 'Enter keywords, verses, or parables...',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  color: AppTheme.onSurface.withOpacity(0.3),
                ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.outlineVariant.withOpacity(0.2),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.secondary,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              'TRENDING:',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
            ),
            _buildTrendingTag(context, 'Psalms 23'),
            _buildTrendingTag(context, 'The Beatitudes'),
            _buildTrendingTag(context, 'Genesis 1'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendingTag(BuildContext context, String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.secondary,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildBookmarksSection(BuildContext context) {
    final bookmarks = _getSampleBookmarks();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Verses',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                  ),
            ),
            Text(
              '${bookmarks.length} BOOKMARKS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.4),
                  ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 48),
          height: 1,
          color: AppTheme.outlineVariant.withOpacity(0.1),
        ),
        ...bookmarks.map((bookmark) => _buildBookmarkItem(context, bookmark)),
      ],
    );
  }

  Widget _buildBookmarkItem(BuildContext context, Bookmark bookmark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 120,
            color: AppTheme.secondary,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bookmark.reference,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark,
                        color: AppTheme.secondary,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bookmark.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.onSurface.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Added ${bookmark.dateAdded}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurface.withOpacity(0.3),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              image: DecorationImage(
                image: const NetworkImage(
                  'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=200',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.grey.withOpacity(0.2),
                  BlendMode.saturation,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"Thy word is a lamp unto my feet, and a light unto my path."',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.onSurface.withOpacity(0.4),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Bookmark> _getSampleBookmarks() {
    return [
      Bookmark(
        reference: 'Matthew 5:3',
        text: '"Blessed are the poor in spirit, for theirs is the kingdom of heaven."',
        dateAdded: 'Dec 12, 2023',
      ),
      Bookmark(
        reference: 'Psalm 46:10',
        text: '"Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth."',
        dateAdded: 'Nov 28, 2023',
      ),
      Bookmark(
        reference: 'John 1:1',
        text: '"In the beginning was the Word, and the Word was with God, and the Word was God."',
        dateAdded: 'Oct 15, 2023',
      ),
      Bookmark(
        reference: 'Lamentations 3:22-23',
        text: '"Because of the Lord\'s great love we are not consumed, for his compassions never fail. They are new every morning; great is your faithfulness."',
        dateAdded: 'Sep 02, 2023',
      ),
    ];
  }
}
