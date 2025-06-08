import 'package:flutter/material.dart';

/// 海洋主题颜色定义
/// 基于 docs/ocean.ts 标准实现
class OceanTheme {
  // ===== 标准对比度 - 浅色模式 =====
  static const _primaryLight = Color(0xFF006782);
  static const _onPrimaryLight = Color(0xFFFFFFFF);
  static const _primaryContainerLight = Color(0xFFB8EAFF);
  static const _onPrimaryContainerLight = Color(0xFF001F29);
  static const _secondaryLight = Color(0xFF4D616C);
  static const _onSecondaryLight = Color(0xFFFFFFFF);
  static const _secondaryContainerLight = Color(0xFFD0E6F2);
  static const _onSecondaryContainerLight = Color(0xFF081E27);
  static const _tertiaryLight = Color(0xFF5D5B7D);
  static const _onTertiaryLight = Color(0xFFFFFFFF);
  static const _tertiaryContainerLight = Color(0xFFE3DFFF);
  static const _onTertiaryContainerLight = Color(0xFF191836);
  static const _errorLight = Color(0xFFBA1A1A);
  static const _onErrorLight = Color(0xFFFFFFFF);
  static const _errorContainerLight = Color(0xFFFFDAD6);
  static const _onErrorContainerLight = Color(0xFF93000A);
  static const _surfaceLight = Color(0xFFF6FAFD);
  static const _onSurfaceLight = Color(0xFF171C1F);
  static const _onSurfaceVariantLight = Color(0xFF40484C);
  static const _outlineLight = Color(0xFF70787D);
  static const _outlineVariantLight = Color(0xFFC0C8CD);
  static const _scrimLight = Color(0xFF000000);
  static const _inverseSurfaceLight = Color(0xFF2C3134);
  static const _inverseOnSurfaceLight = Color(0xFFEDF1F5);
  static const _inversePrimaryLight = Color(0xFF8BD0EF);
  static const _surfaceDimLight = Color(0xFFD6DADD);
  static const _surfaceBrightLight = Color(0xFFF6FAFD);
  static const _surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const _surfaceContainerLowLight = Color(0xFFF0F4F8);
  static const _surfaceContainerLight = Color(0xFFEAEEF2);
  static const _surfaceContainerHighLight = Color(0xFFE4E9EC);
  static const _surfaceContainerHighestLight = Color(0xFFDFE3E7);

  // ===== 中对比度 - 浅色模式 =====
  static const _primaryLightMediumContrast = Color(0xFF003B4E);
  static const _onPrimaryLightMediumContrast = Color(0xFFFFFFFF);
  static const _primaryContainerLightMediumContrast = Color(0xFF297591);
  static const _onPrimaryContainerLightMediumContrast = Color(0xFFFFFFFF);
  static const _secondaryLightMediumContrast = Color(0xFF253942);
  static const _onSecondaryLightMediumContrast = Color(0xFFFFFFFF);
  static const _secondaryContainerLightMediumContrast = Color(0xFF5B707B);
  static const _onSecondaryContainerLightMediumContrast = Color(0xFFFFFFFF);
  static const _tertiaryLightMediumContrast = Color(0xFF343353);
  static const _onTertiaryLightMediumContrast = Color(0xFFFFFFFF);
  static const _tertiaryContainerLightMediumContrast = Color(0xFF6C698D);
  static const _onTertiaryContainerLightMediumContrast = Color(0xFFFFFFFF);
  static const _errorLightMediumContrast = Color(0xFF740006);
  static const _onErrorLightMediumContrast = Color(0xFFFFFFFF);
  static const _errorContainerLightMediumContrast = Color(0xFFCF2C27);
  static const _onErrorContainerLightMediumContrast = Color(0xFFFFFFFF);
  static const _surfaceLightMediumContrast = Color(0xFFF6FAFD);
  static const _onSurfaceLightMediumContrast = Color(0xFF0D1214);
  static const _onSurfaceVariantLightMediumContrast = Color(0xFF30373B);
  static const _outlineLightMediumContrast = Color(0xFF4C5458);
  static const _outlineVariantLightMediumContrast = Color(0xFF666E73);
  static const _scrimLightMediumContrast = Color(0xFF000000);
  static const _inverseSurfaceLightMediumContrast = Color(0xFF2C3134);
  static const _inverseOnSurfaceLightMediumContrast = Color(0xFFEDF1F5);
  static const _inversePrimaryLightMediumContrast = Color(0xFF8BD0EF);
  static const _surfaceDimLightMediumContrast = Color(0xFFC2C7CB);
  static const _surfaceBrightLightMediumContrast = Color(0xFFF6FAFD);
  static const _surfaceContainerLowestLightMediumContrast = Color(0xFFFFFFFF);
  static const _surfaceContainerLowLightMediumContrast = Color(0xFFF0F4F8);
  static const _surfaceContainerLightMediumContrast = Color(0xFFE4E9EC);
  static const _surfaceContainerHighLightMediumContrast = Color(0xFFD9DDE1);
  static const _surfaceContainerHighestLightMediumContrast = Color(0xFFCED2D6);

  // ===== 高对比度 - 浅色模式 =====
  static const _primaryLightHighContrast = Color(0xFF003040);
  static const _onPrimaryLightHighContrast = Color(0xFFFFFFFF);
  static const _primaryContainerLightHighContrast = Color(0xFF005067);
  static const _onPrimaryContainerLightHighContrast = Color(0xFFFFFFFF);
  static const _secondaryLightHighContrast = Color(0xFF1A2F38);
  static const _onSecondaryLightHighContrast = Color(0xFFFFFFFF);
  static const _secondaryContainerLightHighContrast = Color(0xFF384C56);
  static const _onSecondaryContainerLightHighContrast = Color(0xFFFFFFFF);
  static const _tertiaryLightHighContrast = Color(0xFF2A2948);
  static const _onTertiaryLightHighContrast = Color(0xFFFFFFFF);
  static const _tertiaryContainerLightHighContrast = Color(0xFF474667);
  static const _onTertiaryContainerLightHighContrast = Color(0xFFFFFFFF);
  static const _errorLightHighContrast = Color(0xFF600004);
  static const _onErrorLightHighContrast = Color(0xFFFFFFFF);
  static const _errorContainerLightHighContrast = Color(0xFF98000A);
  static const _onErrorContainerLightHighContrast = Color(0xFFFFFFFF);
  static const _surfaceLightHighContrast = Color(0xFFF6FAFD);
  static const _onSurfaceLightHighContrast = Color(0xFF000000);
  static const _onSurfaceVariantLightHighContrast = Color(0xFF000000);
  static const _outlineLightHighContrast = Color(0xFF262D31);
  static const _outlineVariantLightHighContrast = Color(0xFF434A4F);
  static const _scrimLightHighContrast = Color(0xFF000000);
  static const _inverseSurfaceLightHighContrast = Color(0xFF2C3134);
  static const _inverseOnSurfaceLightHighContrast = Color(0xFFFFFFFF);
  static const _inversePrimaryLightHighContrast = Color(0xFF8BD0EF);
  static const _surfaceDimLightHighContrast = Color(0xFFB5B9BD);
  static const _surfaceBrightLightHighContrast = Color(0xFFF6FAFD);
  static const _surfaceContainerLowestLightHighContrast = Color(0xFFFFFFFF);
  static const _surfaceContainerLowLightHighContrast = Color(0xFFEDF1F5);
  static const _surfaceContainerLightHighContrast = Color(0xFFDFE3E7);
  static const _surfaceContainerHighLightHighContrast = Color(0xFFD0D5D8);
  static const _surfaceContainerHighestLightHighContrast = Color(0xFFC2C7CB);

  /// 获取海洋主题的颜色方案（支持对比度级别）
  static ColorScheme getColorScheme(
    Brightness brightness, [
    String contrastLevel = 'standard',
  ]) {
    if (brightness == Brightness.light) {
      switch (contrastLevel) {
        case 'medium':
          return _getLightMediumContrastScheme();
        case 'high':
          return _getLightHighContrastScheme();
        default:
          return _getLightStandardScheme();
      }
    } else {
      switch (contrastLevel) {
        case 'medium':
          return _getDarkMediumContrastScheme();
        case 'high':
          return _getDarkHighContrastScheme();
        default:
          return _getDarkStandardScheme();
      }
    }
  }

  static ColorScheme _getLightStandardScheme() {
    return const ColorScheme.light(
      primary: _primaryLight,
      onPrimary: _onPrimaryLight,
      primaryContainer: _primaryContainerLight,
      onPrimaryContainer: _onPrimaryContainerLight,
      secondary: _secondaryLight,
      onSecondary: _onSecondaryLight,
      secondaryContainer: _secondaryContainerLight,
      onSecondaryContainer: _onSecondaryContainerLight,
      tertiary: _tertiaryLight,
      onTertiary: _onTertiaryLight,
      tertiaryContainer: _tertiaryContainerLight,
      onTertiaryContainer: _onTertiaryContainerLight,
      error: _errorLight,
      onError: _onErrorLight,
      errorContainer: _errorContainerLight,
      onErrorContainer: _onErrorContainerLight,
      surface: _surfaceLight,
      onSurface: _onSurfaceLight,
      onSurfaceVariant: _onSurfaceVariantLight,
      outline: _outlineLight,
      outlineVariant: _outlineVariantLight,
      scrim: _scrimLight,
      inverseSurface: _inverseSurfaceLight,
      onInverseSurface: _inverseOnSurfaceLight,
      inversePrimary: _inversePrimaryLight,
      surfaceDim: _surfaceDimLight,
      surfaceBright: _surfaceBrightLight,
      surfaceContainerLowest: _surfaceContainerLowestLight,
      surfaceContainerLow: _surfaceContainerLowLight,
      surfaceContainer: _surfaceContainerLight,
      surfaceContainerHigh: _surfaceContainerHighLight,
      surfaceContainerHighest: _surfaceContainerHighestLight,
    );
  }

  static ColorScheme _getLightMediumContrastScheme() {
    return const ColorScheme.light(
      primary: _primaryLightMediumContrast,
      onPrimary: _onPrimaryLightMediumContrast,
      primaryContainer: _primaryContainerLightMediumContrast,
      onPrimaryContainer: _onPrimaryContainerLightMediumContrast,
      secondary: _secondaryLightMediumContrast,
      onSecondary: _onSecondaryLightMediumContrast,
      secondaryContainer: _secondaryContainerLightMediumContrast,
      onSecondaryContainer: _onSecondaryContainerLightMediumContrast,
      tertiary: _tertiaryLightMediumContrast,
      onTertiary: _onTertiaryLightMediumContrast,
      tertiaryContainer: _tertiaryContainerLightMediumContrast,
      onTertiaryContainer: _onTertiaryContainerLightMediumContrast,
      error: _errorLightMediumContrast,
      onError: _onErrorLightMediumContrast,
      errorContainer: _errorContainerLightMediumContrast,
      onErrorContainer: _onErrorContainerLightMediumContrast,
      surface: _surfaceLightMediumContrast,
      onSurface: _onSurfaceLightMediumContrast,
      onSurfaceVariant: _onSurfaceVariantLightMediumContrast,
      outline: _outlineLightMediumContrast,
      outlineVariant: _outlineVariantLightMediumContrast,
      scrim: _scrimLightMediumContrast,
      inverseSurface: _inverseSurfaceLightMediumContrast,
      onInverseSurface: _inverseOnSurfaceLightMediumContrast,
      inversePrimary: _inversePrimaryLightMediumContrast,
      surfaceDim: _surfaceDimLightMediumContrast,
      surfaceBright: _surfaceBrightLightMediumContrast,
      surfaceContainerLowest: _surfaceContainerLowestLightMediumContrast,
      surfaceContainerLow: _surfaceContainerLowLightMediumContrast,
      surfaceContainer: _surfaceContainerLightMediumContrast,
      surfaceContainerHigh: _surfaceContainerHighLightMediumContrast,
      surfaceContainerHighest: _surfaceContainerHighestLightMediumContrast,
    );
  }

  static ColorScheme _getLightHighContrastScheme() {
    return const ColorScheme.light(
      primary: _primaryLightHighContrast,
      onPrimary: _onPrimaryLightHighContrast,
      primaryContainer: _primaryContainerLightHighContrast,
      onPrimaryContainer: _onPrimaryContainerLightHighContrast,
      secondary: _secondaryLightHighContrast,
      onSecondary: _onSecondaryLightHighContrast,
      secondaryContainer: _secondaryContainerLightHighContrast,
      onSecondaryContainer: _onSecondaryContainerLightHighContrast,
      tertiary: _tertiaryLightHighContrast,
      onTertiary: _onTertiaryLightHighContrast,
      tertiaryContainer: _tertiaryContainerLightHighContrast,
      onTertiaryContainer: _onTertiaryContainerLightHighContrast,
      error: _errorLightHighContrast,
      onError: _onErrorLightHighContrast,
      errorContainer: _errorContainerLightHighContrast,
      onErrorContainer: _onErrorContainerLightHighContrast,
      surface: _surfaceLightHighContrast,
      onSurface: _onSurfaceLightHighContrast,
      onSurfaceVariant: _onSurfaceVariantLightHighContrast,
      outline: _outlineLightHighContrast,
      outlineVariant: _outlineVariantLightHighContrast,
      scrim: _scrimLightHighContrast,
      inverseSurface: _inverseSurfaceLightHighContrast,
      onInverseSurface: _inverseOnSurfaceLightHighContrast,
      inversePrimary: _inversePrimaryLightHighContrast,
      surfaceDim: _surfaceDimLightHighContrast,
      surfaceBright: _surfaceBrightLightHighContrast,
      surfaceContainerLowest: _surfaceContainerLowestLightHighContrast,
      surfaceContainerLow: _surfaceContainerLowLightHighContrast,
      surfaceContainer: _surfaceContainerLightHighContrast,
      surfaceContainerHigh: _surfaceContainerHighLightHighContrast,
      surfaceContainerHighest: _surfaceContainerHighestLightHighContrast,
    );
  }

  // ===== 标准对比度 - 深色模式 =====
  static const _primaryDark = Color(0xFF8BD0EF);
  static const _onPrimaryDark = Color(0xFF003544);
  static const _primaryContainerDark = Color(0xFF004E63);
  static const _onPrimaryContainerDark = Color(0xFFB8EAFF);
  static const _secondaryDark = Color(0xFFB4CAD6);
  static const _onSecondaryDark = Color(0xFF1F333C);
  static const _secondaryContainerDark = Color(0xFF354A53);
  static const _onSecondaryContainerDark = Color(0xFFD0E6F2);
  static const _tertiaryDark = Color(0xFFC7C3EA);
  static const _onTertiaryDark = Color(0xFF2E2D4C);
  static const _tertiaryContainerDark = Color(0xFF454364);
  static const _onTertiaryContainerDark = Color(0xFFE3DFFF);
  static const _errorDark = Color(0xFFFFB4AB);
  static const _onErrorDark = Color(0xFF690005);
  static const _errorContainerDark = Color(0xFF93000A);
  static const _onErrorContainerDark = Color(0xFFFFDAD6);
  static const _surfaceDark = Color(0xFF0F1417);
  static const _onSurfaceDark = Color(0xFFDFE3E7);
  static const _onSurfaceVariantDark = Color(0xFFC0C8CD);
  static const _outlineDark = Color(0xFF8A9297);
  static const _outlineVariantDark = Color(0xFF40484C);
  static const _scrimDark = Color(0xFF000000);
  static const _inverseSurfaceDark = Color(0xFFDFE3E7);
  static const _inverseOnSurfaceDark = Color(0xFF2C3134);
  static const _inversePrimaryDark = Color(0xFF006782);
  static const _surfaceDimDark = Color(0xFF0F1417);
  static const _surfaceBrightDark = Color(0xFF353A3D);
  static const _surfaceContainerLowestDark = Color(0xFF0A0F12);
  static const _surfaceContainerLowDark = Color(0xFF171C1F);
  static const _surfaceContainerDark = Color(0xFF1B2023);
  static const _surfaceContainerHighDark = Color(0xFF252B2E);
  static const _surfaceContainerHighestDark = Color(0xFF303539);

  // ===== 中对比度 - 深色模式 =====
  static const _primaryDarkMediumContrast = Color(0xFFADE4FF);
  static const _onPrimaryDarkMediumContrast = Color(0xFF002937);
  static const _primaryContainerDarkMediumContrast = Color(0xFF5399B7);
  static const _onPrimaryContainerDarkMediumContrast = Color(0xFF000000);
  static const _secondaryDarkMediumContrast = Color(0xFFCAE0EC);
  static const _onSecondaryDarkMediumContrast = Color(0xFF132831);
  static const _secondaryContainerDarkMediumContrast = Color(0xFF7F949F);
  static const _onSecondaryContainerDarkMediumContrast = Color(0xFF000000);
  static const _tertiaryDarkMediumContrast = Color(0xFFDCD8FF);
  static const _onTertiaryDarkMediumContrast = Color(0xFF242241);
  static const _tertiaryContainerDarkMediumContrast = Color(0xFF908DB2);
  static const _onTertiaryContainerDarkMediumContrast = Color(0xFF000000);
  static const _errorDarkMediumContrast = Color(0xFFFFD2CC);
  static const _onErrorDarkMediumContrast = Color(0xFF540003);
  static const _errorContainerDarkMediumContrast = Color(0xFFFF5449);
  static const _onErrorContainerDarkMediumContrast = Color(0xFF000000);
  static const _surfaceDarkMediumContrast = Color(0xFF0F1417);
  static const _onSurfaceDarkMediumContrast = Color(0xFFFFFFFF);
  static const _onSurfaceVariantDarkMediumContrast = Color(0xFFD6DDE3);
  static const _outlineDarkMediumContrast = Color(0xFFABB3B8);
  static const _outlineVariantDarkMediumContrast = Color(0xFF8A9196);
  static const _scrimDarkMediumContrast = Color(0xFF000000);
  static const _inverseSurfaceDarkMediumContrast = Color(0xFFDFE3E7);
  static const _inverseOnSurfaceDarkMediumContrast = Color(0xFF262B2E);
  static const _inversePrimaryDarkMediumContrast = Color(0xFF004E66);
  static const _surfaceDimDarkMediumContrast = Color(0xFF0F1417);
  static const _surfaceBrightDarkMediumContrast = Color(0xFF404548);
  static const _surfaceContainerLowestDarkMediumContrast = Color(0xFF04080A);
  static const _surfaceContainerLowDarkMediumContrast = Color(0xFF191E21);
  static const _surfaceContainerDarkMediumContrast = Color(0xFF23292B);
  static const _surfaceContainerHighDarkMediumContrast = Color(0xFF2E3336);
  static const _surfaceContainerHighestDarkMediumContrast = Color(0xFF393E41);

  // ===== 高对比度 - 深色模式 =====
  static const _primaryDarkHighContrast = Color(0xFFDEF3FF);
  static const _onPrimaryDarkHighContrast = Color(0xFF000000);
  static const _primaryContainerDarkHighContrast = Color(0xFF87CCEB);
  static const _onPrimaryContainerDarkHighContrast = Color(0xFF000D14);
  static const _secondaryDarkHighContrast = Color(0xFFDEF3FF);
  static const _onSecondaryDarkHighContrast = Color(0xFF000000);
  static const _secondaryContainerDarkHighContrast = Color(0xFFB0C6D2);
  static const _onSecondaryContainerDarkHighContrast = Color(0xFF000D14);
  static const _tertiaryDarkHighContrast = Color(0xFFF2EEFF);
  static const _onTertiaryDarkHighContrast = Color(0xFF000000);
  static const _tertiaryContainerDarkHighContrast = Color(0xFFC2BEE6);
  static const _onTertiaryContainerDarkHighContrast = Color(0xFF090725);
  static const _errorDarkHighContrast = Color(0xFFFFECE9);
  static const _onErrorDarkHighContrast = Color(0xFF000000);
  static const _errorContainerDarkHighContrast = Color(0xFFFFAEA4);
  static const _onErrorContainerDarkHighContrast = Color(0xFF220001);
  static const _surfaceDarkHighContrast = Color(0xFF0F1417);
  static const _onSurfaceDarkHighContrast = Color(0xFFFFFFFF);
  static const _onSurfaceVariantDarkHighContrast = Color(0xFFFFFFFF);
  static const _outlineDarkHighContrast = Color(0xFFE9F1F6);
  static const _outlineVariantDarkHighContrast = Color(0xFFBCC4C9);
  static const _scrimDarkHighContrast = Color(0xFF000000);
  static const _inverseSurfaceDarkHighContrast = Color(0xFFDFE3E7);
  static const _inverseOnSurfaceDarkHighContrast = Color(0xFF000000);
  static const _inversePrimaryDarkHighContrast = Color(0xFF004E66);
  static const _surfaceDimDarkHighContrast = Color(0xFF0F1417);
  static const _surfaceBrightDarkHighContrast = Color(0xFF4C5154);
  static const _surfaceContainerLowestDarkHighContrast = Color(0xFF000000);
  static const _surfaceContainerLowDarkHighContrast = Color(0xFF1B2023);
  static const _surfaceContainerDarkHighContrast = Color(0xFF2C3134);
  static const _surfaceContainerHighDarkHighContrast = Color(0xFF373C3F);
  static const _surfaceContainerHighestDarkHighContrast = Color(0xFF42474A);

  static ColorScheme _getDarkStandardScheme() {
    return const ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: _onPrimaryDark,
      primaryContainer: _primaryContainerDark,
      onPrimaryContainer: _onPrimaryContainerDark,
      secondary: _secondaryDark,
      onSecondary: _onSecondaryDark,
      secondaryContainer: _secondaryContainerDark,
      onSecondaryContainer: _onSecondaryContainerDark,
      tertiary: _tertiaryDark,
      onTertiary: _onTertiaryDark,
      tertiaryContainer: _tertiaryContainerDark,
      onTertiaryContainer: _onTertiaryContainerDark,
      error: _errorDark,
      onError: _onErrorDark,
      errorContainer: _errorContainerDark,
      onErrorContainer: _onErrorContainerDark,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
      onSurfaceVariant: _onSurfaceVariantDark,
      outline: _outlineDark,
      outlineVariant: _outlineVariantDark,
      scrim: _scrimDark,
      inverseSurface: _inverseSurfaceDark,
      onInverseSurface: _inverseOnSurfaceDark,
      inversePrimary: _inversePrimaryDark,
      surfaceDim: _surfaceDimDark,
      surfaceBright: _surfaceBrightDark,
      surfaceContainerLowest: _surfaceContainerLowestDark,
      surfaceContainerLow: _surfaceContainerLowDark,
      surfaceContainer: _surfaceContainerDark,
      surfaceContainerHigh: _surfaceContainerHighDark,
      surfaceContainerHighest: _surfaceContainerHighestDark,
    );
  }

  static ColorScheme _getDarkMediumContrastScheme() {
    return const ColorScheme.dark(
      primary: _primaryDarkMediumContrast,
      onPrimary: _onPrimaryDarkMediumContrast,
      primaryContainer: _primaryContainerDarkMediumContrast,
      onPrimaryContainer: _onPrimaryContainerDarkMediumContrast,
      secondary: _secondaryDarkMediumContrast,
      onSecondary: _onSecondaryDarkMediumContrast,
      secondaryContainer: _secondaryContainerDarkMediumContrast,
      onSecondaryContainer: _onSecondaryContainerDarkMediumContrast,
      tertiary: _tertiaryDarkMediumContrast,
      onTertiary: _onTertiaryDarkMediumContrast,
      tertiaryContainer: _tertiaryContainerDarkMediumContrast,
      onTertiaryContainer: _onTertiaryContainerDarkMediumContrast,
      error: _errorDarkMediumContrast,
      onError: _onErrorDarkMediumContrast,
      errorContainer: _errorContainerDarkMediumContrast,
      onErrorContainer: _onErrorContainerDarkMediumContrast,
      surface: _surfaceDarkMediumContrast,
      onSurface: _onSurfaceDarkMediumContrast,
      onSurfaceVariant: _onSurfaceVariantDarkMediumContrast,
      outline: _outlineDarkMediumContrast,
      outlineVariant: _outlineVariantDarkMediumContrast,
      scrim: _scrimDarkMediumContrast,
      inverseSurface: _inverseSurfaceDarkMediumContrast,
      onInverseSurface: _inverseOnSurfaceDarkMediumContrast,
      inversePrimary: _inversePrimaryDarkMediumContrast,
      surfaceDim: _surfaceDimDarkMediumContrast,
      surfaceBright: _surfaceBrightDarkMediumContrast,
      surfaceContainerLowest: _surfaceContainerLowestDarkMediumContrast,
      surfaceContainerLow: _surfaceContainerLowDarkMediumContrast,
      surfaceContainer: _surfaceContainerDarkMediumContrast,
      surfaceContainerHigh: _surfaceContainerHighDarkMediumContrast,
      surfaceContainerHighest: _surfaceContainerHighestDarkMediumContrast,
    );
  }

  static ColorScheme _getDarkHighContrastScheme() {
    return const ColorScheme.dark(
      primary: _primaryDarkHighContrast,
      onPrimary: _onPrimaryDarkHighContrast,
      primaryContainer: _primaryContainerDarkHighContrast,
      onPrimaryContainer: _onPrimaryContainerDarkHighContrast,
      secondary: _secondaryDarkHighContrast,
      onSecondary: _onSecondaryDarkHighContrast,
      secondaryContainer: _secondaryContainerDarkHighContrast,
      onSecondaryContainer: _onSecondaryContainerDarkHighContrast,
      tertiary: _tertiaryDarkHighContrast,
      onTertiary: _onTertiaryDarkHighContrast,
      tertiaryContainer: _tertiaryContainerDarkHighContrast,
      onTertiaryContainer: _onTertiaryContainerDarkHighContrast,
      error: _errorDarkHighContrast,
      onError: _onErrorDarkHighContrast,
      errorContainer: _errorContainerDarkHighContrast,
      onErrorContainer: _onErrorContainerDarkHighContrast,
      surface: _surfaceDarkHighContrast,
      onSurface: _onSurfaceDarkHighContrast,
      onSurfaceVariant: _onSurfaceVariantDarkHighContrast,
      outline: _outlineDarkHighContrast,
      outlineVariant: _outlineVariantDarkHighContrast,
      scrim: _scrimDarkHighContrast,
      inverseSurface: _inverseSurfaceDarkHighContrast,
      onInverseSurface: _inverseOnSurfaceDarkHighContrast,
      inversePrimary: _inversePrimaryDarkHighContrast,
      surfaceDim: _surfaceDimDarkHighContrast,
      surfaceBright: _surfaceBrightDarkHighContrast,
      surfaceContainerLowest: _surfaceContainerLowestDarkHighContrast,
      surfaceContainerLow: _surfaceContainerLowDarkHighContrast,
      surfaceContainer: _surfaceContainerDarkHighContrast,
      surfaceContainerHigh: _surfaceContainerHighDarkHighContrast,
      surfaceContainerHighest: _surfaceContainerHighestDarkHighContrast,
    );
  }
}
