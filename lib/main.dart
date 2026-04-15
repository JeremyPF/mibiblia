import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SacredTextApp());
}

class SacredTextApp extends StatelessWidget {
  const SacredTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiBiblia',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
