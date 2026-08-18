import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(Color seedColor) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    );
  }

  static ThemeData dark(Color seedColor) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1220),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    );
  }
}
