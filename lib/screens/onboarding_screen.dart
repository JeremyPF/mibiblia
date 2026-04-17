import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/user_profile_service.dart';
import '../providers/reading_settings_provider.dart';
import '../main.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  // ── Fases ──────────────────────────────────────────────────────────────
  // 0 = splash, 1 = saludo, 2 = plan o libre, 3 = preview ajustes, 4 = bienvenida final
  int _phase = 0;
  bool _wantsPlan = false;

  // ── Animaciones ────────────────────────────────────────────────────────
  late AnimationController _shimmerCtrl;   // degradado del título
  late AnimationController _fadeCtrl;      // fade entre fases
  late Animation<double> _fadeAnim;

  // ── Ajustes preview ────────────────────────────────────────────────────
  double _fontSize    = 20.0;
  double _lineHeight  = 2.0;
  bool   _darkBg      = false;
  String _fontFamily  = 'Newsreader';

  static const _fonts = ReadingSettingsProvider.elegantFonts;
  static const _sampleText =
      '«Porque tanto amó Dios al mundo, que dio a su Hijo único, '
      'para que todo el que crea en él no se pierda, '
      'sino que tenga vida eterna.»\n— Juan 3:16';

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();

    // Auto-avanzar del splash al saludo
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _goToPhase(1);
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _goToPhase(int phase) {
    _fadeCtrl.reverse().then((_) {
      if (mounted) {
        setState(() => _phase = phase);
        _fadeCtrl.forward();
      }
    });
  }

  Future<void> _finish() async {
    // Guardar ajustes
    final settings = ReadingSettingsScope.of(context);
    settings.setFontSize(_fontSize);
    settings.setLineHeight(_lineHeight);
    settings.setDarkMode(_darkBg);
    settings.setFontFamily(_fontFamily);
    // Marcar onboarding completo
    await UserProfileService.completeOnboarding({}, ReadingPlan(
      minutesPerDay: _wantsPlan ? 15 : 0,
      readingTime: 'morning',
      startBook: 'Juan',
      motivationalMessage: '',
      tips: [],
    ));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg ? const Color(0xFF1C1C1C) : const Color(0xFFFAF7F2),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _phase == 0 ? _buildSplash() : _buildPhase(),
      ),
    );
  }

  // ── Splash ─────────────────────────────────────────────────────────────
  Widget _buildSplash() {
    return Center(
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          final shimmer = _shimmerCtrl.value;
          return ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF735B3A),
                Color(0xFFD4A96A),
                Color(0xFF735B3A),
              ],
              stops: [
                (shimmer - 0.4).clamp(0.0, 1.0),
                shimmer.clamp(0.0, 1.0),
                (shimmer + 0.4).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: Text('MiBiblia',
                style: GoogleFonts.notoSerif(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2)),
          );
        },
      ),
    );
  }

  // ── Fases conversacionales ─────────────────────────────────────────────
  Widget _buildPhase() {
    return Column(children: [
      Expanded(child: _buildContent()),
      _buildBottomSheet(),
    ]);
  }

  Widget _buildContent() {
    // Fondo sepia con imagen de biblia simulada
    return Container(
      decoration: BoxDecoration(
        color: _darkBg ? const Color(0xFF2A2218) : const Color(0xFFF5EDD8),
        image: const DecorationImage(
          image: AssetImage('assets/images/bible_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.08,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _buildPhaseContent(),
        ),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case 1: return _buildGreeting();
      case 2: return _buildPlanChoice();
      case 3: return _buildSettingsPreview();
      case 4: return _buildWelcomeFinal();
      default: return const SizedBox();
    }
  }

  Widget _buildGreeting() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('👋', style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 24),
      Text('¡Hola! Bienvenido a MiBiblia',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
              fontSize: 28, fontWeight: FontWeight.w300,
              color: const Color(0xFF3D2E1A))),
      const SizedBox(height: 16),
      Text('Aquí vas a poder leer la Palabra de Dios de una forma diferente — '
          'más cercana, más personal, más tuya. 📖',
          textAlign: TextAlign.center,
          style: GoogleFonts.newsreader(
              fontSize: 17, height: 1.7,
              color: const Color(0xFF5C4A2A))),
    ]);
  }

  Widget _buildPlanChoice() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🤔', style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 20),
      Text('¿Cómo quieres empezar?',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
              fontSize: 26, fontWeight: FontWeight.w300,
              color: const Color(0xFF3D2E1A))),
      const SizedBox(height: 12),
      Text('No hay respuesta incorrecta. Puedes cambiar esto después.',
          textAlign: TextAlign.center,
          style: GoogleFonts.newsreader(
              fontSize: 15, color: const Color(0xFF7A6040),
              fontStyle: FontStyle.italic)),
      const SizedBox(height: 32),
      _ChoiceCard(
        emoji: '📅',
        title: 'Quiero un plan de lectura',
        subtitle: 'Te ayudo a organizar cuánto leer cada día según tu tiempo.',
        selected: _wantsPlan,
        onTap: () => setState(() => _wantsPlan = true),
      ),
      const SizedBox(height: 12),
      _ChoiceCard(
        emoji: '📖',
        title: 'Solo quiero leer',
        subtitle: 'Sin presión. Abres la app y lees lo que quieras.',
        selected: !_wantsPlan,
        onTap: () => setState(() => _wantsPlan = false),
      ),
    ]);
  }

  Widget _buildSettingsPreview() {
    final textStyle = GoogleFonts.getFont(
      _fontFamily,
      fontSize: _fontSize,
      height: _lineHeight,
      color: _darkBg ? const Color(0xFFDEE4DC) : const Color(0xFF2E342F),
    );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('✨', style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 12),
      Text('Personaliza tu lectura',
          style: GoogleFonts.notoSerif(
              fontSize: 22, fontWeight: FontWeight.w300,
              color: _darkBg ? Colors.white70 : const Color(0xFF3D2E1A))),
      const SizedBox(height: 20),
      // Preview del texto
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _darkBg ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Text(_sampleText, style: textStyle, textAlign: TextAlign.center),
      ),
    ]);
  }

  Widget _buildWelcomeFinal() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🙏', style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 24),
      Text('¡Todo listo!',
          style: GoogleFonts.notoSerif(
              fontSize: 32, fontWeight: FontWeight.w300,
              color: const Color(0xFF3D2E1A))),
      const SizedBox(height: 16),
      Text('Que la Palabra de Dios ilumine cada día de tu vida. '
          'Empieza cuando quieras. 🌟',
          textAlign: TextAlign.center,
          style: GoogleFonts.newsreader(
              fontSize: 17, height: 1.7,
              color: const Color(0xFF5C4A2A))),
    ]);
  }

  // ── Bottom sheet ────────────────────────────────────────────────────────
  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: _darkBg
            ? const Color(0xFF1C1C1C).withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.outlineVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            if (_phase == 3) _buildSettingsControls(),
            const SizedBox(height: 12),
            _buildActionButton(),
          ]),
        ),
      ),
    );
  }

  Widget _buildSettingsControls() {
    return Column(children: [
      // Tamaño
      _SliderRow(
        label: 'TAMAÑO',
        value: _fontSize,
        min: 14, max: 28,
        onChanged: (v) => setState(() => _fontSize = v),
      ),
      // Interlineado
      _SliderRow(
        label: 'LÍNEAS',
        value: _lineHeight,
        min: 1.2, max: 3.0,
        onChanged: (v) => setState(() => _lineHeight = v),
      ),
      const SizedBox(height: 8),
      // Fondo + fuente
      Row(children: [
        Text('FONDO', style: _labelStyle),
        const SizedBox(width: 12),
        _BgToggle(dark: false, selected: !_darkBg,
            onTap: () => setState(() => _darkBg = false)),
        const SizedBox(width: 8),
        _BgToggle(dark: true, selected: _darkBg,
            onTap: () => setState(() => _darkBg = true)),
        const Spacer(),
        Text('FUENTE', style: _labelStyle),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _fontFamily,
          underline: const SizedBox(),
          isDense: true,
          style: GoogleFonts.newsreader(
              fontSize: 13,
              color: _darkBg ? Colors.white70 : const Color(0xFF2E342F)),
          items: _fonts.map((f) => DropdownMenuItem(
              value: f,
              child: Text(f, style: GoogleFonts.getFont(f, fontSize: 13))
          )).toList(),
          onChanged: (v) { if (v != null) setState(() => _fontFamily = v); },
        ),
      ]),
    ]);
  }

  TextStyle get _labelStyle => TextStyle(
      fontSize: 10,
      letterSpacing: 1.5,
      color: AppTheme.outline.withOpacity(0.6));

  Widget _buildActionButton() {
    String label;
    VoidCallback action;
    switch (_phase) {
      case 1: label = 'Continuar  →'; action = () => _goToPhase(2); break;
      case 2: label = 'Siguiente  →'; action = () => _goToPhase(3); break;
      case 3: label = 'Aplicar ajustes  ✓'; action = () => _goToPhase(4); break;
      case 4: label = 'Empezar a leer  📖'; action = _finish; break;
      default: label = ''; action = () {};
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: action,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: GoogleFonts.newsreader(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _ChoiceCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceCard({required this.emoji, required this.title,
      required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.secondary.withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppTheme.secondary : AppTheme.outlineVariant.withOpacity(0.3),
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.newsreader(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: const Color(0xFF2E342F))),
            const SizedBox(height: 3),
            Text(subtitle, style: GoogleFonts.newsreader(
                fontSize: 13, color: AppTheme.outline, height: 1.4)),
          ])),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.secondary, size: 20),
        ]),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.label, required this.value,
      required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 72,
          child: Text(label, style: const TextStyle(
              fontSize: 10, letterSpacing: 1.5,
              color: AppTheme.outline))),
      Expanded(child: Slider(
        value: value.clamp(min, max),
        min: min, max: max,
        activeColor: AppTheme.secondary,
        inactiveColor: AppTheme.outlineVariant.withOpacity(0.3),
        onChanged: onChanged,
      )),
      SizedBox(width: 32,
          child: Text(value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 11, color: AppTheme.outline))),
    ]);
  }
}

class _BgToggle extends StatelessWidget {
  final bool dark, selected;
  final VoidCallback onTap;
  const _BgToggle({required this.dark, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: selected ? AppTheme.secondary : AppTheme.outlineVariant.withOpacity(0.4),
            width: selected ? 2 : 1),
      ),
    ),
  );
}
