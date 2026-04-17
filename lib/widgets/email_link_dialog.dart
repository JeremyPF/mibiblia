import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/reading_progress_service.dart';
import '../theme/app_theme.dart';

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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await ReadingProgressService.linkEmail(email);
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
              'Ingresa tu correo para guardar tu progreso en la nube. '
              'Úsalo en cualquier dispositivo para recuperarlo.',
              style: GoogleFonts.newsreader(
                  fontSize: 14, color: AppTheme.outline, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: GoogleFonts.newsreader(fontSize: 16),
              onSubmitted: (_) => _link(),
              decoration: InputDecoration(
                hintText: 'tu@correo.com',
                hintStyle: GoogleFonts.newsreader(
                    color: AppTheme.outline.withOpacity(0.5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
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
                      style: TextStyle(
                          color: AppTheme.outline.withOpacity(0.7))),
                ),
                FilledButton(
                  onPressed: _loading ? null : _link,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.secondary),
                  child: _loading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Vincular'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
