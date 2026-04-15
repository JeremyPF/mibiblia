import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopAppBar extends StatelessWidget {
  final double opacity;

  const TopAppBar({super.key, this.opacity = 0.6});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
      ),
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Título centrado
                Text(
                  'MiBiblia',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                // Botón menú izquierda
                Positioned(
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.secondary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                // Botón búsqueda derecha
                Positioned(
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.secondary),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
