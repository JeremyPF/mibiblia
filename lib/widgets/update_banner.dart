import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';

class UpdateBanner extends StatelessWidget {
  final UpdateService service;

  const UpdateBanner({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final show = service.availableUpdate != null;
        return AnimatedSlide(
          offset: show ? Offset.zero : const Offset(0, 1.5),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: show ? _buildCard(context) : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final isReady = service.isReady;
    final isDownloading = service.isDownloading;
    final tag = service.availableUpdate?.tagName ?? '';

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de progreso de descarga
            if (isDownloading)
              LinearProgressIndicator(
                value: service.downloadProgress,
                backgroundColor: AppTheme.outlineVariant.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                minHeight: 2,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  // Icono
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isReady
                          ? Icons.system_update_alt
                          : Icons.download_outlined,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReady
                              ? 'Lista para instalar'
                              : isDownloading
                                  ? 'Descargando...'
                                  : 'Nueva versión',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          isDownloading
                              ? '${(service.downloadProgress * 100).toStringAsFixed(0)}%'
                              : tag,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppTheme.secondary,
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Acción
                  if (isReady)
                    TextButton(
                      onPressed: service.installUpdate,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text('INSTALAR'),
                    )
                  else if (!isDownloading)
                    TextButton(
                      onPressed: service.downloadUpdate,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text('DESCARGAR'),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppTheme.outline,
                      onPressed: service.dismiss,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
