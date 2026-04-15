import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_drawer.dart';
import '../models/bible_book.dart';

class BooksNavigatorScreen extends StatelessWidget {
  const BooksNavigatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const SideDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: TopAppBar(opacity: 0.85),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda - Contexto
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 128, right: 64),
                    child: _buildLeftColumn(context),
                  ),
                ),
                // Columna derecha - Lista de libros
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 128),
                    child: _buildBooksColumn(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ARCHIVE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'The Books of Truth',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
              ),
        ),
        const SizedBox(height: 32),
        Text(
          'A collection of sacred literature spanning millennia, organized into the historical foundations and the new covenant.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                color: AppTheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 48),
        // Imagen decorativa
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              image: DecorationImage(
                image: const NetworkImage(
                  'https://images.unsplash.com/photo-1505682634904-d7c8d95cdc50?w=400',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.grey.withOpacity(0.4),
                  BlendMode.saturation,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBooksColumn(BuildContext context) {
    return Column(
      children: [
        _buildTestamentSection(
          context,
          'I.',
          'Old Testament',
          _getOldTestamentBooks(),
        ),
        const SizedBox(height: 96),
        _buildTestamentSection(
          context,
          'II.',
          'New Testament',
          _getNewTestamentBooks(),
        ),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildTestamentSection(
    BuildContext context,
    String number,
    String title,
    List<BibleBook> books,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.secondary,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 30,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 6,
            crossAxisSpacing: 48,
            mainAxisSpacing: 24,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) => _buildBookItem(context, books[index]),
        ),
      ],
    );
  }

  Widget _buildBookItem(BuildContext context, BibleBook book) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.outlineVariant.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              book.id.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurface.withOpacity(0.4),
                  ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                book.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 24,
                    ),
              ),
            ),
            Icon(
              _getIconData(book.icon),
              color: AppTheme.secondary.withOpacity(0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'history_edu':
        return Icons.history_edu;
      case 'music_note':
        return Icons.music_note;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'mail':
        return Icons.mail;
      case 'visibility':
        return Icons.visibility;
      default:
        return Icons.book;
    }
  }

  List<BibleBook> _getOldTestamentBooks() {
    return [
      BibleBook(id: 1, name: 'Génesis', testament: 'OT', chapters: 50, icon: 'history_edu'),
      BibleBook(id: 2, name: 'Éxodo', testament: 'OT', chapters: 40, icon: 'history_edu'),
      BibleBook(id: 3, name: 'Levítico', testament: 'OT', chapters: 27, icon: 'history_edu'),
      BibleBook(id: 4, name: 'Números', testament: 'OT', chapters: 36, icon: 'history_edu'),
      BibleBook(id: 5, name: 'Deuteronomio', testament: 'OT', chapters: 34, icon: 'history_edu'),
      BibleBook(id: 19, name: 'Salmos', testament: 'OT', chapters: 150, icon: 'music_note'),
    ];
  }

  List<BibleBook> _getNewTestamentBooks() {
    return [
      BibleBook(id: 40, name: 'Mateo', testament: 'NT', chapters: 28, icon: 'auto_stories'),
      BibleBook(id: 41, name: 'Marcos', testament: 'NT', chapters: 16, icon: 'auto_stories'),
      BibleBook(id: 42, name: 'Lucas', testament: 'NT', chapters: 24, icon: 'auto_stories'),
      BibleBook(id: 43, name: 'Juan', testament: 'NT', chapters: 21, icon: 'auto_stories'),
      BibleBook(id: 45, name: 'Romanos', testament: 'NT', chapters: 16, icon: 'mail'),
      BibleBook(id: 66, name: 'Apocalipsis', testament: 'NT', chapters: 22, icon: 'visibility'),
    ];
  }
}
