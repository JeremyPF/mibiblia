import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../widgets/verse_image_generator.dart';

class ShareService {
  static final ScreenshotController _screenshotController = ScreenshotController();

  static Future<void> shareVerseAsImage({
    required BuildContext context,
    required String bookName,
    required int chapterNumber,
    required int verseNumber,
    required String verseText,
  }) async {
    try {
      // Crear el widget de la imagen
      final imageWidget = VerseImageWidget(
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
      );

      // Capturar la imagen
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        imageWidget,
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
      );

      if (imageBytes == null) {
        throw Exception('No se pudo generar la imagen');
      }

      // Guardar la imagen temporalmente
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/verse_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Compartir la imagen
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: '$verseText\n\n$bookName $chapterNumber:$verseNumber',
        subject: '$bookName $chapterNumber:$verseNumber',
      );

      // Limpiar el archivo temporal después de compartir
      if (result.status == ShareResultStatus.success) {
        await imageFile.delete();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> shareVerseAsText({
    required String bookName,
    required int chapterNumber,
    required int verseNumber,
    required String verseText,
  }) async {
    final text = '"$verseText"\n\n$bookName $chapterNumber:$verseNumber\n\nCompartido desde MiBiblia';
    
    await Share.share(
      text,
      subject: '$bookName $chapterNumber:$verseNumber',
    );
  }
}
