import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../providers/reading_settings_provider.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'settings',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SettingsModal(),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  // Cuando el usuario mueve un slider, ocultamos el modal y mostramos el label
  String? _activeSliderLabel;
  double? _activeSliderValue;
  bool _isSliding = false;

  void _onSliderStart(String label) {
    setState(() {
      _activeSliderLabel = label;
      _isSliding = true;
    });
  }

  void _onSliderEnd() {
    setState(() => _isSliding = false);
    // Pequeño delay para que el usuario vea el valor final
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _activeSliderLabel = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ReadingSettingsScope.of(context);
    return Stack(
      children: [
        // Modal principal — se oculta al deslizar
        AnimatedOpacity(
          opacity: _isSliding ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
                      const SizedBox(height: 16),
                      _buildSlider(
                        context, settings, 'TAMAÑO',
                        settings.fontSize, 14, 32,
                        (v) => settings.setFontSize(v),
                        (v) { _onSliderStart('TAMAÑO'); setState(() => _activeSliderValue = v); },
                        _onSliderEnd,
                      ),
                      _buildSlider(
                        context, settings, 'INTERLINEADO',
                        settings.lineHeight, 1.2, 3.0,
                        (v) => settings.setLineHeight(v),
                        (v) { _onSliderStart('INTERLINEADO'); setState(() => _activeSliderValue = v); },
                        _onSliderEnd,
                      ),
                      _buildSlider(
                        context, settings, 'ESPACIADO',
                        settings.letterSpacing, -1.0, 4.0,
                        (v) => settings.setLetterSpacing(v),
                        (v) { _onSliderStart('ESPACIADO'); setState(() => _activeSliderValue = v); },
                        _onSliderEnd,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: _buildAlignmentPicker(context, settings)),
                          const SizedBox(width: 12),
                          _buildDarkModeToggle(context, settings),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildColorPicker(context, settings),
                      const SizedBox(height: 12),
                      _buildFontPicker(context, settings),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Preview label al deslizar — centrado en pantalla
        if (_activeSliderLabel != null)
          AnimatedOpacity(
            opacity: _isSliding ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _activeSliderLabel!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary,
                            letterSpacing: 2.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (_activeSliderValue ?? 0).toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            color: AppTheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context,
    ReadingSettingsProvider settings,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    ValueChanged<double> onChangeStart,
    VoidCallback onChangeEnd,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
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
              onChangeStart: onChangeStart,
              onChanged: (v) {
                onChanged(v);
                setState(() => _activeSliderValue = v);
              },
              onChangeEnd: (_) => onChangeEnd(),
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
              color:
                  settings.isDarkMode ? AppTheme.secondary : AppTheme.outline,
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
        Text('COLOR',
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: c.$1,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.secondary : Colors.transparent,
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

  Widget _buildFontPicker(BuildContext context, settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FUENTE',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(letterSpacing: 1.5)),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ReadingSettingsProvider.elegantFonts.length,
            itemBuilder: (context, i) {
              final font = ReadingSettingsProvider.elegantFonts[i];
              final isSelected = settings.fontFamily == font;
              return GestureDetector(
                onTap: () => settings.setFontFamily(font),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondary
                          : AppTheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    font,
                    style: GoogleFonts.getFont(
                      font,
                      fontSize: 13,
                      color: isSelected ? AppTheme.secondary : AppTheme.outline,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
