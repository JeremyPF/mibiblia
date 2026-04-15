import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/side_drawer.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ReadingSettingsScope.of(context);
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 128),
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildReadingSection(context, settings),
                const SizedBox(height: 48),
                _buildAboutSection(context),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERENCES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Settings',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
        ),
      ],
    );
  }

  Widget _buildReadingSection(BuildContext context, settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Experience',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 24),

        // Font Size
        _buildSlider(context, 'Font Size', settings.fontSize, 14, 32,
            (v) => settings.setFontSize(v)),

        // Line Height
        _buildSlider(context, 'Line Height', settings.lineHeight, 1.2, 3.0,
            (v) => settings.setLineHeight(v)),

        // Letter Spacing
        _buildSlider(context, 'Letter Spacing', settings.letterSpacing, -1.0, 4.0,
            (v) => settings.setLetterSpacing(v)),

        // Dark Mode
        _buildSwitch(context, 'Dark Mode', settings.isDarkMode,
            (v) => settings.setDarkMode(v)),

        const SizedBox(height: 8),

        // Text Alignment
        _buildAlignmentPicker(context, settings),

        const SizedBox(height: 24),

        // Text Color
        _buildColorPicker(context, settings),
      ],
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value,
      double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
              Text(value.toStringAsFixed(1),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppTheme.secondary)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.secondary,
            inactiveColor: AppTheme.outlineVariant.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(BuildContext context, String label, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
          Switch(value: value, activeColor: AppTheme.secondary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAlignmentPicker(BuildContext context, settings) {
    final options = [
      (TextAlign.left, Icons.format_align_left),
      (TextAlign.center, Icons.format_align_center),
      (TextAlign.right, Icons.format_align_right),
      (TextAlign.justify, Icons.format_align_justify),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Text Alignment',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
          Row(
            children: options.map((opt) {
              final isSelected = settings.textAlign == opt.$1;
              return GestureDetector(
                onTap: () => settings.setTextAlign(opt.$1),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
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
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, settings) {
    final colors = [
      (const Color(0xFF2E342F), 'Default'),
      (const Color(0xFF1A1A2E), 'Night'),
      (const Color(0xFF3B2F2F), 'Sepia'),
      (const Color(0xFF1B3A2D), 'Forest'),
      (const Color(0xFF735B3A), 'Warm'),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Text Color',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: colors.map((c) {
              final isSelected = settings.textColor == c.$1;
              return GestureDetector(
                onTap: () => settings.setTextColor(c.$1),
                child: Tooltip(
                  message: c.$2,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.$1,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.secondary : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppTheme.secondary.withOpacity(0.4), blurRadius: 6)]
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
        const SizedBox(height: 24),
        _buildInfoRow(context, 'Version', '1.0.0'),
        _buildInfoRow(context, 'Translation', 'The Message (ES)'),
        _buildInfoRow(context, 'Purpose', 'Personal Use Only'),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: AppTheme.onSurface.withOpacity(0.6),
                  )),
          Text(value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
