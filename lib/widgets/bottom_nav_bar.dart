import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/books_navigator_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.85),
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.menu_book, 'Leer', 0),
              _buildNavItem(context, Icons.grid_view, 'Índice', 1),
              _buildNavItem(context, Icons.bookmark_border, 'Marcas', 2),
              _buildNavItem(context, Icons.settings, 'Ajustes', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppTheme.secondary
        : AppTheme.onSurface.withOpacity(0.4);

    return InkWell(
      onTap: () {
        if (index == currentIndex) return;
        
        Widget screen;
        switch (index) {
          case 0:
            screen = const HomeScreen();
            break;
          case 1:
            screen = const BooksNavigatorScreen();
            break;
          case 2:
            screen = const BookmarksScreen();
            break;
          case 3:
            screen = const SettingsScreen();
            break;
          default:
            return;
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
