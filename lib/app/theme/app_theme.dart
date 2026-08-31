import 'package:flutter/material.dart';

abstract final class AppColors {
  static const cream = Color(0xFFF8F2E9);
  static const surface = Color(0xFFFFFDFC);
  static const dustyRose = Color(0xFFC98582);
  static const paleRose = Color(0xFFF0D9D5);
  static const sage = Color(0xFF9FA992);
  static const paleSage = Color(0xFFDDE1D4);
  static const sand = Color(0xFFDDCBB8);
  static const lavender = Color(0xFFD1CBD4);
  static const ink = Color(0xFF4C3E3B);
  static const secondaryInk = Color(0xFF756966);
  static const line = Color(0xFFE4D9CD);
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.dustyRose,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ).copyWith(
        primary: AppColors.dustyRose,
        onPrimary: Colors.white,
        secondary: AppColors.sage,
        onSecondary: AppColors.ink,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        outline: AppColors.line,
        error: const Color(0xFFA94747),
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.dustyRose, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.paleRose,
      surfaceTintColor: Colors.transparent,
      height: 70,
    ),
    dividerColor: AppColors.line,
  );
}

TextStyle emotionalTitle(BuildContext context, {double size = 34}) => TextStyle(
  fontFamily: 'CormorantGaramond',
  fontSize: size,
  height: .98,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.onSurface,
);
