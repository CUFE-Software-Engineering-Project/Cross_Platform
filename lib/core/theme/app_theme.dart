// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'Palette.dart';

final appTheme = ThemeData.dark().copyWith(
  primaryColor: Palette.primary,
  scaffoldBackgroundColor: Palette.background,
  cardColor: Palette.cardBackground,
  dividerColor: Palette.divider,

  colorScheme: ColorScheme.dark(
    primary: Palette.primary,
    secondary: Palette.primary,
    surface: Palette.cardBackground,
    background: Palette.background,
    error: Palette.error,
    onPrimary: Palette.textPrimary,
    onSecondary: Palette.textPrimary,
    onSurface: Palette.textPrimary,
    onBackground: Palette.textPrimary,
    onError: Palette.textPrimary,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Palette.background,
    foregroundColor: Palette.textPrimary,
    elevation: 0,
    centerTitle: false,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Palette.background,
    selectedItemColor: Palette.primary,
    unselectedItemColor: Palette.icons,
    type: BottomNavigationBarType.fixed,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Palette.inputBackground,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Palette.inputBorder),
      borderRadius: BorderRadius.circular(8),
    ),

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Palette.inputBorderFocused),
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Palette.primary,
    foregroundColor: Palette.textPrimary,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: Palette.cardBackground,
    contentTextStyle: const TextStyle(color: Palette.textPrimary),
  ),

  // Disable splash effects globally
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
);
