import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";

class AppTheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: MaterialColors.primary,
    onPrimary: MaterialColors.onPrimary,
    primaryContainer:MaterialColors.primary,
    onPrimaryContainer: MaterialColors.onPrimary,
    secondary: MaterialColors.secondary,
    onSecondary: MaterialColors.onSecondary,
    error: MaterialColors.error,
    onError: MaterialColors.error,
    background: MaterialColors.primaryBackgroundColor,
    onBackground: MaterialColors.secondaryTextColor,
    surface: MaterialColors.surface,
    onSurface: MaterialColors.onSurface,
  );

  static const ColorScheme lightColorDefault = ColorScheme(
    brightness: Brightness.light,
    primary: MaterialColors.onPrimary,
    onPrimary: MaterialColors.onPrimary,
    primaryContainer:MaterialColors.onPrimary,
    onPrimaryContainer: MaterialColors.onPrimary,
    secondary: MaterialColors.secondary,
    onSecondary: MaterialColors.onSecondary,
    error: MaterialColors.error,
    onError: MaterialColors.error,
    background: MaterialColors.onSecondary,
    onBackground: MaterialColors.primaryBackgroundColor,
    surface: MaterialColors.surface,
    onSurface: MaterialColors.secondary,
  );



  static ThemeData lightThemeData = ThemeData.from(colorScheme: lightColorScheme);
  static ThemeData lightThemeDefault = ThemeData.from(colorScheme: lightColorDefault);

}