import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';

Future<void> showAIChatSheet(
    BuildContext context, String verseRef, String verseText) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ai_chat',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) =>
        _AIChatSheet(verseRef: verseRef, verseText: verseText),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ),
  );
}

class _AIChatSheet extends StatefulWidget {
  final String verseRef;
  final String verseText;
  const _AIChatSheet({required this.verseRef, required this.verseText});

  @override
  State<_AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<_AIChatSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _loading = false;

  // Sugerencias rápidas
  static const _suggestions = [
    '¿Qué significa este versículo?',
    '¿Cómo aplicarlo hoy?',
    '¿Qué contexto histórico tiene?',
    '¿Hay versículos relacionados?',
  ];

  @override
  void initState() {
    super.initState();
    // Mensaje inicial de contexto
    _messages.add(_Msg(
      role: 'assistant',
      text: 'Hola 👋 Estoy aquí para ayudarte a entender **${widget.verseRef}**. '
          '¿Qué quieres saber?',
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add(_Msg(role: 'user', text: text.trim()));
      _loading = true;
    });
    _scrollToBottom();

    try {
      // Solo enviar mensajes user/assistant previos (no el inicial de bienvenida)
      final history = <Map<String, String>>[];
      for (int i = 1; i < _messages.length - 1; i++) {
        history.add({'role': _messages[i].role, 'content': _messages[i].text});
      }

      final reply = await GroqService.ask(
        verseRef: widget.verseRef,
        verseText: widget.verseText,
        userMessage: text.trim(),
        history: history.cast<Map<String, String>>(),
      );
      if (mounted) {
        setState(() {
          _messages.add(_Msg(role: 'assistant', text: reply));
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Msg(
              role: 'assistant',
              text: 'Hubo un error al conectar. Intenta de nuevo.'));
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 28, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(children: [
                Center(child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 16, color: AppTheme.secondary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat bíblico',
                          style: GoogleFonts.newsreader(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(widget.verseRef,
                          style: GoogleFonts.newsreader(
                              fontSize: 11,
                              color: AppTheme.secondary,
                              letterSpacing: 0.5)),
                    ],
                  )),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppTheme.outline.withOpacity(0.5),
                  ),
                ]),
              ]),
            ),
            Divider(color: AppTheme.outlineVariant.withOpacity(0.15), height: 16),
            // Mensajes
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) return _buildTyping();
                  return _buildBubble(_messages[i]);
                },
              ),
            ),
            // Sugerencias (solo al inicio)
            if (_messages.length == 1)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _suggestions.map((s) => GestureDetector(
                    onTap: () => _send(s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.secondary.withOpacity(0.25)),
                      ),
                      child: Text(s,
                          style: GoogleFonts.newsreader(
                              fontSize: 12, color: AppTheme.secondary)),
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 8),
            // Input
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: GoogleFonts.newsreader(fontSize: 15),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: 'Pregunta algo sobre este versículo...',
                      hintStyle: GoogleFonts.newsreader(
                          fontSize: 14,
                          color: AppTheme.outline.withOpacity(0.4)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: AppTheme.outlineVariant.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: AppTheme.secondary)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_ctrl.text),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _loading
                          ? AppTheme.secondary.withOpacity(0.4)
                          : AppTheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: AppTheme.secondary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.secondary
                    : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.newsreader(
                  fontSize: 14,
                  height: 1.55,
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              size: 14, color: AppTheme.secondary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String role, text;
  const _Msg({required this.role, required this.text});
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: AppTheme.outline.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    ),
  );
}
