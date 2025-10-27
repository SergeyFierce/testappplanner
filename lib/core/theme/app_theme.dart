import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';

class AppTheme {
  static ThemeData light(AccentColorOption accent) {
    final scheme = ColorScheme.fromSeed(seedColor: accent.color);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primary.withOpacity(0.1),
        secondarySelectedColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withOpacity(0.6)),
      ),
    );
  }

  static ThemeData dark(AccentColorOption accent) {
    final scheme = ColorScheme.fromSeed(
        seedColor: accent.color,
        brightness: Brightness.dark,
      );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.primary.withOpacity(0.2),
        secondarySelectedColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withOpacity(0.8)),
      ),
    );
  }
}
