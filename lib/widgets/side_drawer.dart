import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'The Folio',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 48),
              _buildDrawerItem(
                context,
                Icons.history_edu,
                'Old Testament',
                false,
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(
                context,
                Icons.auto_stories,
                'New Testament',
                true,
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(
                context,
                Icons.bookmark,
                'Bookmarks',
                false,
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(
                context,
                Icons.edit_note,
                'Study Notes',
                false,
              ),
              const Spacer(),
              Center(
                child: Text(
                  '© MMXXIV',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurface.withOpacity(0.4),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.secondaryContainer.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppTheme.secondary
                  : AppTheme.onSurface.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 24),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: isActive
                        ? AppTheme.secondary
                        : AppTheme.onSurface.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
