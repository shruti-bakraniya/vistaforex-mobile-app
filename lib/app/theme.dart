import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: kAccent,
        onPrimary: Colors.white,
        secondary: kAccent,
        onSecondary: Colors.white,
        error: dark ? kDarkDown : kLightDown,
        onError: Colors.white,
        surface: dark ? kDarkSurface : kLightSurface,
        onSurface: dark ? kDarkText : kLightText,
      ),
      scaffoldBackgroundColor: dark ? kDarkBg : kLightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      fontFamily: 'Helvetica Neue',
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: dark ? kDarkText : kLightText),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
