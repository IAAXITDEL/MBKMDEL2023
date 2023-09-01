import 'package:flutter/material.dart';

ThemeData tsOneThemeData = ThemeData(
  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),

  // turn this off if you want to use the default color scheme
  colorScheme: tsOneColorScheme,
  primaryColor: const Color(0xFFE32526),
  backgroundColor: tsOneColorScheme.background,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  fontFamily: 'Poppins',
);

ColorScheme tsOneColorScheme = const ColorScheme(
  primary: Color(0xFFE32526),
  primaryContainer: Color(0xFFBB1F1F),
  secondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF7A7A7A),
  surface: Color(0xFFF5F5F5),
  background: Color(0xFFFDFDFD),
  error: Colors.redAccent,
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFF000000),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);

class TsOneColor {
  static const Color primary = Color(0xFFE32526);  // accordion header expanded
  static const Color primaryContainer = Color(0xFFBB1F1F);
  static const Color primaryFaded = Color(0xFFFBDEDE); // accordion border not expanded
  static const Color secondary = Color(0xFFFFFFFF); // accordion header not expanded
  static const Color secondaryContainer = Color(0xFF7A7A7A); // input border
  static const Color surface = Color(0xFFF5F5F5); // card background and input background
  static const Color background = Color(0xFFFDFDFD); // all page background
  static const Color error = Colors.redAccent;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
}

TextTheme tsOneTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  displayMedium: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  displaySmall: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  headlineLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  headlineMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  headlineSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  titleLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  bodyLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  bodyMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  bodySmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  labelLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  labelMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  labelSmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: tsOneColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
);