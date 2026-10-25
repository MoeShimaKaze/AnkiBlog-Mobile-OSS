import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _darkBackground = Color(0xFF10131A);
  static const _lightBackground = Color(0xFFF6F7FB);

  static ThemeData dark(Color seedColor) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF171B24),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkBackground,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.07),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF151923).withValues(alpha: 0.94),
        indicatorColor: seedColor.withValues(alpha: 0.2),
      ),
    );
  }

  static ThemeData light(Color seedColor) {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBackground,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.84),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
