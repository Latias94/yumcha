import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData getLightTheme([ColorScheme? colorScheme]) {
    final effectiveColorScheme = colorScheme ?? AppColors.lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: effectiveColorScheme,
      typography: AppTypography.typography,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: effectiveColorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: effectiveColorScheme.surface,
      ),
    );
  }

  static ThemeData getDarkTheme([ColorScheme? colorScheme]) {
    final effectiveColorScheme = colorScheme ?? AppColors.darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: effectiveColorScheme,
      typography: AppTypography.typography,
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: effectiveColorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: effectiveColorScheme.surface,
      ),
    );
  }

  // 为了向后兼容性
  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();
}
