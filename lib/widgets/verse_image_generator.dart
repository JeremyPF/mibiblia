import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VerseImageWidget extends StatelessWidget {
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String verseText;

  const VerseImageWidget({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.verseText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      padding: const EdgeInsets.all(80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceContainerLow,
            AppTheme.surfaceContainerHigh,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo o título de la app
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'MiBiblia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.onSurface.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          
          // Texto del versículo
          Text(
            verseText,
            style: const TextStyle(
              fontSize: 42,
              height: 1.6,
              fontWeight: FontWeight.w400,
              color: AppTheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Referencia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$bookName $chapterNumber:$verseNumber',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
