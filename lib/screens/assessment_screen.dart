import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/reading_plan_service.dart';
import 'plan_result_screen.dart';

class _Question {
  final String text;
  final List<String> options;
  const _Question(this.text, this.options);
}

// 4 etapas × 2 preguntas cada una
const _stages = [
  // Etapa 1: Responsabilidades y tiempo
  [
    _Question('¿Cuántas horas trabajas o estudias al día?', [
      'Menos de 4 horas',
      'Entre 4 y 6 horas',
      'Entre 6 y 8 horas',
      'Más de 8 horas',
    ]),
    _Question('¿Cuánto tiempo libre tienes en un día normal?', [
      'Más de 3 horas',
      'Entre 1 y 3 horas',
      'Menos de 1 hora',
      'Casi ninguno',
    ]),
  ],
  // Etapa 2: Hábitos de lectura
  [
    _Question('¿Con qué frecuencia lees la Biblia actualmente?', [
      'Todos los días',
      'Algunas veces a la semana',
      'Rara vez',
      'Nunca o casi nunca',
    ]),
    _Question('¿Cuánto tiempo puedes concentrarte leyendo sin distraerte?', [
      'Más de 30 minutos',
      'Entre 15 y 30 minutos',
      'Entre 5 y 15 minutos',
      'Menos de 5 minutos',
    ]),
  ],
  // Etapa 3: Dificultades
  [
    _Question('¿Qué te dificulta más leer la Biblia?', [
      'No tengo tiempo',
      'Me da sueño o me aburro',
      'No entiendo lo que leo',
      'No siento motivación',
    ]),
    _Question('¿Cómo te sientes después de leer la Biblia?', [
      'Inspirado y con paz',
      'Confundido o sin entender',
      'Indiferente',
      'Culpable por no leer más',
    ]),
  ],
  // Etapa 4: Metas y preferencias
  [
    _Question('¿Cuál es tu meta principal al leer la Biblia?', [
      'Conocer más a Dios',
      'Crecer espiritualmente',
      'Entender la Biblia completa',
      'Desarrollar el hábito',
    ]),
    _Question('¿En qué momento del día prefieres leer?', [
      'Por la mañana (antes de empezar el día)',
      'Al mediodía (en un descanso)',
      'Por la tarde (al terminar actividades)',
      'Por la noche (antes de dormir)',
    ]),
  ],
];

const _stageTitles = [
  'Tu tiempo y responsabilidades',
  'Tus hábitos de lectura',
  'Tus dificultades',
  'Tus metas',
];

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  int _stage = 0;
  int _questionInStage = 0;
  // answers[stage][question] = optionIndex
  final List<List<int?>> _answers =
      List.generate(4, (_) => List.filled(2, null));

  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _animateNext(VoidCallback action) {
    _ctrl.reverse().then((_) {
      setState(action);
      _ctrl.forward();
    });
  }

  void _selectOption(int optionIndex) {
    setState(() => _answers[_stage][_questionInStage] = optionIndex);
  }

  void _next() {
    if (_answers[_stage][_questionInStage] == null) return;

    if (_questionInStage == 0) {
      // Siguiente pregunta en la misma etapa
      _animateNext(() => _questionInStage = 1);
    } else if (_stage < 3) {
      // Siguiente etapa
      _animateNext(() {
        _stage++;
        _questionInStage = 0;
      });
    } else {
      // Fin del test
      final flat = <String, int>{};
      for (int s = 0; s < 4; s++) {
        for (int q = 0; q < 2; q++) {
          flat['s${s}_q$q'] = _answers[s][q] ?? 0;
        }
      }
      final plan = ReadingPlanService.generatePlan(flat);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlanResultScreen(answers: flat, plan: plan),
        ),
      );
    }
  }

  void _back() {
    if (_questionInStage == 1) {
      _animateNext(() => _questionInStage = 0);
    } else if (_stage > 0) {
      _animateNext(() {
        _stage--;
        _questionInStage = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _stages[_stage][_questionInStage];
    final selected = _answers[_stage][_questionInStage];
    final totalSteps = 8; // 4 etapas × 2 preguntas
    final currentStep = _stage * 2 + _questionInStage + 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E342F), Color(0xFF3D2E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con progreso
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_stage > 0 || _questionInStage > 0)
                          GestureDetector(
                            onTap: _back,
                            child: Icon(Icons.arrow_back_ios,
                                size: 18,
                                color: AppTheme.onSecondary.withOpacity(0.6)),
                          ),
                        const Spacer(),
                        Text(
                          '$currentStep / $totalSteps',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            letterSpacing: 2.0,
                            color: AppTheme.onSecondary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: currentStep / totalSteps,
                        backgroundColor:
                            AppTheme.onSecondary.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.secondary),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ETAPA ${_stage + 1}  ·  ${_stageTitles[_stage].toUpperCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: AppTheme.secondary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Pregunta + opciones
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            question.text,
                            style: GoogleFonts.notoSerif(
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                              color: AppTheme.onSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 36),
                          ...question.options.asMap().entries.map((e) =>
                              _OptionTile(
                                label: e.value,
                                isSelected: selected == e.key,
                                onTap: () => _selectOption(e.key),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Botón siguiente
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: selected != null ? _next : null,
                    style: TextButton.styleFrom(
                      backgroundColor: selected != null
                          ? AppTheme.secondary
                          : AppTheme.onSecondary.withOpacity(0.08),
                      foregroundColor: AppTheme.onSecondary,
                      disabledForegroundColor:
                          AppTheme.onSecondary.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _stage == 3 && _questionInStage == 1
                          ? 'VER MI PLAN'
                          : 'CONTINUAR',
                      style: GoogleFonts.inter(
                          fontSize: 12, letterSpacing: 3.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondary.withOpacity(0.25)
              : AppTheme.onSecondary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.secondary
                : AppTheme.onSecondary.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.newsreader(
                  fontSize: 16,
                  color: isSelected
                      ? AppTheme.onSecondary
                      : AppTheme.onSecondary.withOpacity(0.75),
                  height: 1.4,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_outline,
                  size: 18, color: AppTheme.secondary),
          ],
        ),
      ),
    );
  }
}
