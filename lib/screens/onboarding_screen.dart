import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'assessment_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E342F), // onSurface oscuro
              Color(0xFF3D2E1A), // marrón cálido
              Color(0xFF735B3A), // secondary
              Color(0xFFA68D6A), // secondary claro
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo / Icono
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.onSecondary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.onSecondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: AppTheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Título
                    Text(
                      'Bienvenido a MiBiblia',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.onSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Descripción
                    Text(
                      'MiBiblia es una app que te permitirá crecer en la lectura bíblica y en tu comunión con Dios.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 18,
                        color: AppTheme.onSecondary.withOpacity(0.85),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No es únicamente la Biblia — te permitirá leer la Palabra de Dios hasta desarrollar el hábito de buscarlo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 16,
                        color: AppTheme.onSecondary.withOpacity(0.65),
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Botón continuar
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const AssessmentScreen()),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.onSecondary.withOpacity(0.15),
                          foregroundColor: AppTheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppTheme.onSecondary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          'COMENZAR',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
