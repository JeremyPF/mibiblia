import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/user_profile_service.dart';
import '../services/bible_service.dart';
import 'reading_screen.dart';
import 'search_screen.dart';

class PlanResultScreen extends StatefulWidget {
  final Map<String, int> answers;
  final ReadingPlan plan;

  const PlanResultScreen({
    super.key,
    required this.answers,
    required this.plan,
  });

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _startReading() async {
    await UserProfileService.completeOnboarding(widget.answers, widget.plan);
    if (!mounted) return;

    final books = await BibleService.getAvailableBooks();
    if (!mounted) return;

    // Intentar abrir el libro recomendado, si no el primero disponible
    final book = books.firstWhere(
      (b) => b.name == widget.plan.startBook,
      orElse: () => books.first,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => ReadingScreen(
          bookId: book.id,
          bookName: book.name,
          chapterNumber: 1,
          onSearchTap: () => Navigator.of(ctx).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E342F), Color(0xFF3D2E1A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    // Icono de éxito
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.secondary.withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          size: 32, color: AppTheme.secondary),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Tu plan está listo',
                      style: GoogleFonts.notoSerif(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.motivationalMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 15,
                        color: AppTheme.onSecondary.withOpacity(0.7),
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Tarjetas del plan
                    Row(
                      children: [
                        Expanded(
                          child: _PlanCard(
                            icon: Icons.timer_outlined,
                            label: 'DIARIO',
                            value: '${plan.minutesPerDay} min',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlanCard(
                            icon: Icons.schedule_outlined,
                            label: 'HORARIO',
                            value: plan.readingTimeLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlanCard(
                            icon: Icons.menu_book_outlined,
                            label: 'INICIO',
                            value: plan.startBook,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Tips
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.onSecondary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.onSecondary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONSEJOS PARA TI',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              letterSpacing: 2.5,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...plan.tips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: GoogleFonts.newsreader(
                                          fontSize: 14,
                                          color: AppTheme.onSecondary
                                              .withOpacity(0.75),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _startReading,
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'COMENZAR A LEER',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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

class _PlanCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PlanCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.onSecondary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.secondary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.secondary, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              letterSpacing: 2.0,
              color: AppTheme.secondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 13,
              color: AppTheme.onSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
