import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color blue10 = Color(0xFF001F33);
  static const Color blue20 = Color(0xFF003E66);
  static const Color blue30 = Color(0xFF005D99);
  static const Color blue40 = Color(0xFF007BCC);
  static const Color blue80 = Color(0xFF66CCFF);
  static const Color blue90 = Color(0xFFB3E5FF);

  static const Color darkBlue10 = Color(0xFF0D1B2A);
  static const Color darkBlue20 = Color(0xFF1A2E42);
  static const Color darkBlue30 = Color(0xFF26415A);
  static const Color darkBlue40 = Color(0xFF415A77);
  static const Color darkBlue80 = Color(0xFFA3B8CC);
  static const Color darkBlue90 = Color(0xFFD1DCE6);

  static const Color yellow10 = Color(0xFF1A1300);
  static const Color yellow20 = Color(0xFF332600);
  static const Color yellow30 = Color(0xFF4D3900);
  static const Color yellow40 = Color(0xFF664C00);
  static const Color yellow80 = Color(0xFFCCB366);
  static const Color yellow90 = Color(0xFFE6D9B3);

  static const Color red10 = Color(0xFF330D0D);
  static const Color red20 = Color(0xFF661A1A);
  static const Color red30 = Color(0xFF992626);
  static const Color red40 = Color(0xFFCC3333);
  static const Color red80 = Color(0xFFFFB3B3);
  static const Color red90 = Color(0xFFFFD9D9);

  static const Color grey10 = Color(0xFF121212);
  static const Color grey20 = Color(0xFF2E2E2E);
  static const Color grey80 = Color(0xFFCCCCCC);
  static const Color grey90 = Color(0xFFE6E6E6);
  static const Color grey95 = Color(0xFFF3F3F3);
  static const Color grey99 = Color(0xFFFFFBFE);

  static const Color blueGrey30 = Color(0xFF4A5B6B);
  static const Color blueGrey50 = Color(0xFF7A8A9A);
  static const Color blueGrey60 = Color(0xFF95A5B5);
  static const Color blueGrey80 = Color(0xFFC0CDD9);
  static const Color blueGrey90 = Color(0xFFE0E6ED);

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: blue40,
    onPrimary: Colors.white,
    primaryContainer: blue90,
    onPrimaryContainer: blue10,
    inversePrimary: blue80,
    secondary: darkBlue40,
    onSecondary: Colors.white,
    secondaryContainer: darkBlue90,
    onSecondaryContainer: darkBlue10,
    tertiary: yellow40,
    onTertiary: Colors.white,
    tertiaryContainer: yellow90,
    onTertiaryContainer: yellow10,
    error: red40,
    onError: Colors.white,
    errorContainer: red90,
    onErrorContainer: red10,
    surface: grey99,
    onSurface: grey10,
    surfaceContainerHighest: blueGrey90,
    onSurfaceVariant: blueGrey30,
    outline: blueGrey50,
    outlineVariant: blueGrey80,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: grey20,
    onInverseSurface: grey95,
    surfaceTint: blue40,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: blue80,
    onPrimary: blue20,
    primaryContainer: blue30,
    onPrimaryContainer: blue90,
    inversePrimary: blue40,
    secondary: darkBlue80,
    onSecondary: darkBlue20,
    secondaryContainer: darkBlue30,
    onSecondaryContainer: darkBlue90,
    tertiary: yellow80,
    onTertiary: yellow20,
    tertiaryContainer: yellow30,
    onTertiaryContainer: yellow90,
    error: red80,
    onError: red20,
    errorContainer: red30,
    onErrorContainer: red90,
    surface: grey10,
    onSurface: grey80,
    surfaceContainerHighest: blueGrey30,
    onSurfaceVariant: blueGrey80,
    outline: blueGrey60,
    outlineVariant: blueGrey30,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: grey90,
    onInverseSurface: grey20,
    surfaceTint: blue80,
  );
}
