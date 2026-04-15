import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores del sistema de diseño
  static const Color secondary = Color(0xFF735B3A);
  static const Color secondaryContainer = Color(0xFFFEDDB3);
  static const Color onSecondary = Color(0xFFFFF8F2);
  static const Color background = Color(0xFFF9FAF6);
  static const Color onSurface = Color(0xFF2E342F);
  static const Color surfaceContainerLow = Color(0xFFF3F4EF);
  static const Color outline = Color(0xFF767C76);
  static const Color outlineVariant = Color(0xFFADB4AC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5F5E5E),
      secondary: secondary,
      surface: background,
      onSurface: onSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSerif(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.notoSerif(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 2.0,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 3.0,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background.withOpacity(0.85),
      elevation: 0,
      iconTheme: const IconThemeData(color: secondary),
      titleTextStyle: GoogleFonts.notoSerif(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        color: onSurface,
        letterSpacing: 1.0,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1B1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5F5E5E),
      secondary: Color(0xFFA68D6A),
      surface: Color(0xFF1A1B1A),
      onSurface: Color(0xFFDEE4DC),
    ),
  );
}
