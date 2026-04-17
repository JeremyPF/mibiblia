import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/reading_progress_service.dart';
import '../services/bible_service.dart';
import '../services/user_profile_service.dart';
import '../services/notification_service.dart';
import '../widgets/side_drawer.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/app_toast.dart';
import 'reading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalBibleChapters = 1189;

  int _totalRead = 0;
  int _streak = 0;
  bool _loading = true;
  TimeOfDay? _alarmTime;

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  // Texto diario — versículos de Juan y Salmos (Proverbios como proxy)
  static const _dailyVerses = [
    _DailyVerse('Juan 3:16',
        'Porque tanto amó Dios al mundo, que dio a su Hijo único, para que todo el que crea en él no se pierda, sino que tenga vida eterna.'),
    _DailyVerse('Juan 14:6',
        'Yo soy el camino, la verdad y la vida. Nadie llega al Padre sino por mí.'),
    _DailyVerse('Juan 1:1',
        'En el principio ya existía la Palabra. La Palabra estaba con Dios, y la Palabra era Dios.'),
    _DailyVerse('Proverbios 3:5',
        'Confía en el Señor de todo corazón y no te apoyes en tu propio entendimiento.'),
    _DailyVerse('Proverbios 4:23',
        'Por encima de todo, cuida tu corazón, porque de él mana la vida.'),
    _DailyVerse('Juan 8:12',
        'Yo soy la luz del mundo. El que me sigue no andará en tinieblas, sino que tendrá la luz de la vida.'),
    _DailyVerse('Proverbios 16:9',
        'El hombre hace sus planes, pero el Señor dirige sus pasos.'),
  ];

  static const _tips = [
    '📖  Lee en voz alta — activa más partes del cerebro y mejora la retención.',
    '✍️  Escribe una frase que te impacte después de cada capítulo.',
    '🌅  Leer en la mañana, antes de revisar el teléfono, cambia el tono del día.',
    '🔁  Releer un capítulo al día siguiente consolida lo que aprendiste.',
    '🤫  Busca un lugar tranquilo — la Palabra necesita espacio para hablar.',
    '🙏  Empieza con una oración corta antes de leer.',
    '📅  La consistencia importa más que la cantidad. Un capítulo al día es suficiente.',
  ];

  _DailyVerse get _todayVerse {
    final day = DateTime.now().day;
    return _dailyVerses[day % _dailyVerses.length];
  }

  String get _todayTip {
    final day = DateTime.now().day;
    return _tips[day % _tips.length];
  }

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic);
    _load();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final total = await ReadingProgressService.getTotalRead();
    final streak = await _calcStreak();
    final savedAlarm = await NotificationService.getSavedAlarm();
    if (!mounted) return;
    setState(() {
      _totalRead = total;
      _streak = streak;
      _alarmTime = savedAlarm;
      _loading = false;
    });
    _progressCtrl.forward();
  }

  Future<int> _calcStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('read_dates')?.toSet() ?? {};
    if (dates.isEmpty) return 0;
    int streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = '${day.year}-${day.month}-${day.day}';
      if (!dates.contains(key)) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _pickAlarm() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppTheme.secondary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final ok = await NotificationService.scheduleDailyReminder(picked);
      setState(() => _alarmTime = picked);
      if (mounted) {
        showAppToast(
          context,
          ok
              ? 'Recordatorio a las ${picked.format(context)} 🔔'
              : 'No se pudo configurar el recordatorio',
          icon: ok ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
        );
      }
    }
  }

  void _openReading() async {
    final books = await BibleService.getAvailableBooks();
    if (!mounted || books.isEmpty) return;
    final last = await UserProfileService.getLastPosition();
    final book = last != null
        ? books.firstWhere((b) => b.id == last['bookId'],
            orElse: () => books.first)
        : books.first;
    final chapter = last?['chapter'] ?? 1;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReadingScreen(
          bookId: book.id,
          bookName: book.name,
          chapterNumber: chapter),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(opacity: 1.0, showSubtitle: false),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.secondary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 28),
                    _buildDailyVerse(),
                    const SizedBox(height: 28),
                    _buildProgressRing(),
                    const SizedBox(height: 28),
                    _buildStreakAndAlarm(),
                    const SizedBox(height: 28),
                    _buildTip(),
                    const SizedBox(height: 28),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Secciones ──────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? '🌅 Buenos días'
        : hour < 18 ? '☀️ Buenas tardes'
        : '🌙 Buenas noches';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(greeting,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.secondary, letterSpacing: 1.5)),
      const SizedBox(height: 6),
      Text('MiBiblia',
          style: GoogleFonts.notoSerif(
              fontSize: 36, fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.onSurface)),
    ]);
  }

  Widget _buildDailyVerse() {
    final verse = _todayVerse;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_stories_outlined,
              size: 14, color: AppTheme.secondary),
          const SizedBox(width: 6),
          Text('VERSÍCULO DEL DÍA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.secondary, letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 12),
        Text('«${verse.text}»',
            style: GoogleFonts.newsreader(
                fontSize: 15, height: 1.7,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85))),
        const SizedBox(height: 8),
        Text('— ${verse.reference}',
            style: GoogleFonts.newsreader(
                fontSize: 12, color: AppTheme.secondary,
                letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildProgressRing() {
    final percent = (_totalRead / _totalBibleChapters).clamp(0.0, 1.0);
    return Row(children: [
      // Círculo animado
      AnimatedBuilder(
        animation: _progressAnim,
        builder: (_, __) => SizedBox(
          width: 120, height: 120,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 120, height: 120,
              child: CircularProgressIndicator(
                value: percent * _progressAnim.value,
                strokeWidth: 8,
                backgroundColor: AppTheme.outlineVariant.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(AppTheme.secondary),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$_totalRead',
                  style: GoogleFonts.notoSerif(
                      fontSize: 28, fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface)),
              Text('caps',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.outline, letterSpacing: 1)),
            ]),
          ]),
        ),
      ),
      const SizedBox(width: 24),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PROGRESO BÍBLICO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.secondary, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text('$_totalRead de $_totalBibleChapters capítulos',
            style: GoogleFonts.newsreader(fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('${(percent * 100).toStringAsFixed(1)}% de la Biblia',
            style: GoogleFonts.newsreader(
                fontSize: 13, color: AppTheme.outline,
                fontStyle: FontStyle.italic)),
      ])),
    ]);
  }

  Widget _buildStreakAndAlarm() {
    return Row(children: [
      // Racha
      Expanded(
        child: _InfoCard(
          child: Row(children: [
            _StreakFlame(streak: _streak),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RACHA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.secondary, letterSpacing: 1.5)),
              Text('$_streak días',
                  style: GoogleFonts.notoSerif(
                      fontSize: 22, fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface)),
            ]),
          ]),
        ),
      ),
      const SizedBox(width: 12),
      // Alarma
      Expanded(
        child: GestureDetector(
          onTap: _pickAlarm,
          child: _InfoCard(
            child: Row(children: [
              Icon(
                _alarmTime != null
                    ? Icons.alarm_on_rounded
                    : Icons.alarm_add_rounded,
                color: AppTheme.secondary, size: 28),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('RECORDATORIO',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.secondary, letterSpacing: 1.5)),
                Text(
                  _alarmTime != null
                      ? _alarmTime!.format(context)
                      : 'Configurar',
                  style: GoogleFonts.notoSerif(
                      fontSize: 16, fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface)),
              ]),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.outlineVariant.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('CONSEJO DEL DÍA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.outline, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(_todayTip,
            style: GoogleFonts.newsreader(
                fontSize: 14, height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
      ]),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _openReading,
        icon: const Icon(Icons.menu_book_rounded, size: 18),
        label: const Text('Continuar leyendo'),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.newsreader(fontSize: 16),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _DailyVerse {
  final String reference, text;
  const _DailyVerse(this.reference, this.text);
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.outlineVariant.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.15)),
    ),
    child: child,
  );
}

class _StreakFlame extends StatefulWidget {
  final int streak;
  const _StreakFlame({required this.streak});
  @override
  State<_StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<_StreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final active = widget.streak > 0;
    return ScaleTransition(
      scale: active ? _scale : const AlwaysStoppedAnimation(1.0),
      child: Text(active ? '🔥' : '💤',
          style: const TextStyle(fontSize: 28)),
    );
  }
}
