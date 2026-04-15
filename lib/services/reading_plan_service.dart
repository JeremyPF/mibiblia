import 'user_profile_service.dart';

class ReadingPlanService {
  /// Genera un plan de lectura personalizado basado en las respuestas del test.
  ///
  /// Claves de answers: 's{stage}_q{question}' → índice de opción (0-3)
  /// Etapa 0: tiempo/responsabilidades
  /// Etapa 1: hábitos de lectura
  /// Etapa 2: dificultades
  /// Etapa 3: metas y preferencias
  static ReadingPlan generatePlan(Map<String, int> a) {
    // ── Calcular minutos/día ──────────────────────────────────────────────
    // s0_q0: horas de trabajo (0=<4h, 1=4-6h, 2=6-8h, 3=>8h)
    // s0_q1: tiempo libre (0=>3h, 1=1-3h, 2=<1h, 3=casi ninguno)
    final workLoad = a['s0_q0'] ?? 1;
    final freeTime = a['s0_q1'] ?? 1;
    // Más trabajo + menos tiempo libre = menos minutos recomendados
    final baseMinutes = [20, 15, 10, 7];
    final freeBonus = [10, 5, 0, -3];
    final minutes =
        (baseMinutes[workLoad] + freeBonus[freeTime]).clamp(5, 30);

    // ── Hora de lectura ───────────────────────────────────────────────────
    // s3_q1: preferencia horaria (0=mañana, 1=mediodía, 2=tarde, 3=noche)
    final timePreference = a['s3_q1'] ?? 0;
    final readingTimes = ['morning', 'afternoon', 'afternoon', 'night'];
    final readingTime = readingTimes[timePreference];

    // ── Libro de inicio ───────────────────────────────────────────────────
    // s2_q0: dificultad principal (0=tiempo, 1=sueño/aburrimiento,
    //                              2=no entiende, 3=sin motivación)
    // s3_q0: meta (0=conocer a Dios, 1=crecer, 2=biblia completa, 3=hábito)
    final difficulty = a['s2_q0'] ?? 3;
    final goal = a['s3_q0'] ?? 3;

    String startBook;
    if (difficulty == 2 || goal == 2) {
      // No entiende o quiere leer completa → empezar por Juan (narrativo y claro)
      startBook = 'Juan';
    } else if (difficulty == 1 || difficulty == 3) {
      // Aburrimiento o sin motivación → Proverbios (corto, práctico, diario)
      startBook = 'Proverbios';
    } else {
      // Falta de tiempo o meta de crecer → Mateo (evangelio completo)
      startBook = 'Mateo';
    }

    // ── Mensaje motivacional ──────────────────────────────────────────────
    final messages = [
      'Cada minuto con la Palabra transforma tu corazón. ¡Empieza hoy!',
      'La constancia es más valiosa que la cantidad. $minutes minutos al día cambiarán tu vida.',
      'Dios honra a quienes lo buscan con lo que tienen. ¡Tú puedes!',
      'No se trata de leer mucho, sino de dejar que la Palabra te lea a ti.',
    ];
    final motivationalMessage = messages[difficulty];

    // ── Tips personalizados ───────────────────────────────────────────────
    final tips = <String>[];

    if (freeTime >= 2) {
      tips.add('Aprovecha pequeños momentos: 5 min en el descanso ya cuentan.');
    }
    if (difficulty == 1) {
      tips.add('Lee en voz alta o escucha audio-biblia para mantenerte activo.');
    }
    if (difficulty == 2) {
      tips.add('Usa una Biblia de estudio o notas para entender el contexto.');
    }
    if (difficulty == 3) {
      tips.add('Empieza con un solo versículo y medita en él durante el día.');
    }
    if (workLoad >= 2) {
      tips.add('Pon una alarma fija — la consistencia vence a la inspiración.');
    }
    if (tips.isEmpty) {
      tips.add('Lleva un diario de lo que Dios te habla cada día.');
    }

    return ReadingPlan(
      minutesPerDay: minutes,
      readingTime: readingTime,
      startBook: startBook,
      motivationalMessage: motivationalMessage,
      tips: tips,
    );
  }
}
