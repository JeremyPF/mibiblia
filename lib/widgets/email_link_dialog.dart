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
  // Paso 2: PIN
  bool _pinStep = false;
  final List<String> _pin = [];

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToPin() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    setState(() { _pinStep = true; _error = null; });
  }

  void _onPinDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin.add(d));
    if (_pin.length == 4) _confirmPin();
  }

  void _onPinDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _confirmPin() async {
    setState(() => _loading = true);
    await ReadingProgressService.linkEmail(
        _emailCtrl.text.trim(), _pin.join());
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _pinStep ? _buildPinStep() : _buildEmailStep(),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.mail_outline, color: AppTheme.secondary, size: 22),
        const SizedBox(width: 10),
        Text('Vincular correo',
            style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      Text('Ingresa tu correo para guardar tu progreso en la nube.',
          style: GoogleFonts.newsreader(fontSize: 14, color: AppTheme.outline, height: 1.5)),
      const SizedBox(height: 20),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        style: GoogleFonts.newsreader(fontSize: 16),
        onSubmitted: (_) => _goToPin(),
        decoration: InputDecoration(
          hintText: 'tu@correo.com',
          hintStyle: GoogleFonts.newsreader(color: AppTheme.outline.withOpacity(0.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.secondary)),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
      ],
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Ahora no',
              style: TextStyle(color: AppTheme.outline.withOpacity(0.7))),
        ),
        FilledButton(
          onPressed: _goToPin,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.secondary),
          child: const Text('Continuar'),
        ),
      ]),
    ]);
  }

  Widget _buildPinStep() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.lock_outline, color: AppTheme.secondary, size: 32),
      const SizedBox(height: 12),
      Text('Crea tu PIN de 4 dígitos',
          style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Lo necesitarás para recuperar tu cuenta en otro dispositivo.',
          style: GoogleFonts.newsreader(fontSize: 13, color: AppTheme.outline, height: 1.5),
          textAlign: TextAlign.center),
      const SizedBox(height: 24),
      // Indicadores de dígitos
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) {
        final filled = i < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppTheme.secondary : Colors.transparent,
            border: Border.all(
                color: filled
                    ? AppTheme.secondary
                    : AppTheme.outlineVariant.withOpacity(0.5),
                width: 1.5),
          ),
        );
      })),
      const SizedBox(height: 24),
      if (_loading)
        const CircularProgressIndicator(color: AppTheme.secondary)
      else
        _buildNumpad(),
    ]);
  }

  Widget _buildNumpad() {
    final digits = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: digits.map((d) {
        if (d.isEmpty) return const SizedBox();
        return TextButton(
          onPressed: d == '⌫' ? _onPinDelete : () => _onPinDigit(d),
          child: Text(d,
              style: GoogleFonts.newsreader(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface)),
        );
      }).toList(),
    );
  }
}
