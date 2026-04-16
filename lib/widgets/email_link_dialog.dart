import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../services/reading_progress_service.dart';
import '../theme/app_theme.dart';

/// Muestra el diálogo de vinculación de correo.
Future<void> showEmailLinkDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _EmailLinkDialog(),
  );
}

class _EmailLinkDialog extends StatefulWidget {
  const _EmailLinkDialog();
  @override
  State<_EmailLinkDialog> createState() => _EmailLinkDialogState();
}

class _EmailLinkDialogState extends State<_EmailLinkDialog> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.sendOtp(email);
      setState(() { _otpSent = true; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error al enviar el código. Intenta de nuevo.'; _loading = false; });
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailCtrl.text.trim();
    final token = _otpCtrl.text.trim();
    if (token.length < 6) {
      setState(() => _error = 'El código tiene 6 dígitos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final ok = await SupabaseService.verifyOtp(email, token);
    if (!ok) {
      setState(() { _error = 'Código incorrecto o expirado'; _loading = false; });
      return;
    }
    // Migrar progreso anónimo al usuario autenticado
    final anonId = await ReadingProgressService.getAnonId();
    final local = await ReadingProgressService.getReadChapters();
    await SupabaseService.migrateAnonProgress(anonId, local);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.mail_outline, color: AppTheme.secondary, size: 22),
              const SizedBox(width: 10),
              Text('Vincular correo',
                  style: GoogleFonts.newsreader(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(
              _otpSent
                  ? 'Ingresa el código de 6 dígitos que enviamos a ${_emailCtrl.text.trim()}'
                  : 'Vincula tu progreso a un correo para que nunca se pierda, incluso si reinstalás la app.',
              style: GoogleFonts.newsreader(
                  fontSize: 14, color: AppTheme.outline, height: 1.5),
            ),
            const SizedBox(height: 20),
            if (!_otpSent)
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                style: GoogleFonts.newsreader(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'tu@correo.com',
                  hintStyle: GoogleFonts.newsreader(color: AppTheme.outline.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.secondary),
                  ),
                ),
              )
            else
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 6,
                style: GoogleFonts.newsreader(fontSize: 22, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.secondary),
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  child: Text('Ahora no',
                      style: TextStyle(color: AppTheme.outline.withOpacity(0.7))),
                ),
                FilledButton(
                  onPressed: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.secondary),
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_otpSent ? 'Verificar' : 'Enviar código'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
