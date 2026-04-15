import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'side_drawer.dart';

class TopAppBar extends StatelessWidget {
  final double opacity;

  const TopAppBar({super.key, this.opacity = 0.6});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.85),
      ),
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppTheme.secondary),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'MiBiblia',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.secondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
