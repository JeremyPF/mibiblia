import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'settings',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SettingsModal(),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ReadingSettingsScope.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSlider(context, settings, 'Tamaño',
                    settings.fontSize, 14, 32, (v) => settings.setFontSize(v)),
                _buildSlider(context, settings, 'Interlineado',
                    settings.lineHeight, 1.2, 3.0, (v) => settings.setLineHeight(v)),
                _buildSlider(context, settings, 'Espaciado',
                    settings.letterSpacing, -1.0, 4.0, (v) => settings.setLetterSpacing(v)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildAlignmentPicker(context, settings)),
                    const SizedBox(width: 16),
                    _buildDarkModeToggle(context, settings),
                  ],
                ),
                const SizedBox(height: 12),
                _buildColorPicker(context, settings),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context, settings, String label,
      double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(letterSpacing: 1.5)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppTheme.secondary,
              inactiveColor: AppTheme.outlineVariant.withOpacity(0.3),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              value.toStringAsFixed(1),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.secondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentPicker(BuildContext context, settings) {
    final options = [
      (TextAlign.left, Icons.format_align_left),
      (TextAlign.center, Icons.format_align_center),
      (TextAlign.justify, Icons.format_align_justify),
    ];
    return Row(
      children: options.map((opt) {
        final isSelected = settings.textAlign == opt.$1;
        return GestureDetector(
          onTap: () => settings.setTextAlign(opt.$1),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.secondary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppTheme.secondary
                    : AppTheme.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Icon(opt.$2,
                size: 18,
                color: isSelected ? AppTheme.secondary : AppTheme.outline),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, settings) {
    return GestureDetector(
      onTap: () => settings.setDarkMode(!settings.isDarkMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: settings.isDarkMode
              ? AppTheme.secondary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: settings.isDarkMode
                ? AppTheme.secondary
                : AppTheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 18,
              color: settings.isDarkMode ? AppTheme.secondary : AppTheme.outline,
            ),
            const SizedBox(width: 6),
            Text(
              settings.isDarkMode ? 'Oscuro' : 'Claro',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: settings.isDarkMode
                        ? AppTheme.secondary
                        : AppTheme.outline,
                    letterSpacing: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, settings) {
    final colors = [
      (const Color(0xFF2E342F), 'Default'),
      (const Color(0xFF1A1A2E), 'Noche'),
      (const Color(0xFF3B2F2F), 'Sepia'),
      (const Color(0xFF1B3A2D), 'Bosque'),
      (const Color(0xFF735B3A), 'Cálido'),
    ];
    return Row(
      children: [
        Text('Color',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(letterSpacing: 1.5)),
        const SizedBox(width: 16),
        ...colors.map((c) {
          final isSelected = settings.textColor == c.$1;
          return GestureDetector(
            onTap: () => settings.setTextColor(c.$1),
            child: Tooltip(
              message: c.$2,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c.$1,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.secondary
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppTheme.secondary.withOpacity(0.4),
                              blurRadius: 6)
                        ]
                      : null,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
