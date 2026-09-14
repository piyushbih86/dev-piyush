import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorConstants.darkBackground,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: ColorConstants.accent,
        secondary: ColorConstants.gold,
        surface: ColorConstants.darkSurface,
        error: ColorConstants.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.darkBackground,
        foregroundColor: ColorConstants.darkText,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorConstants.darkSurface,
        indicatorColor: ColorConstants.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? ColorConstants.accent
                : ColorConstants.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? ColorConstants.accent
                : ColorConstants.darkTextSecondary,
          );
        }),
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ColorConstants.lightBackground,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: ColorConstants.accent,
        secondary: ColorConstants.gold,
        surface: ColorConstants.lightSurface,
        error: ColorConstants.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.lightBackground,
        foregroundColor: ColorConstants.lightText,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x14000000),
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorConstants.lightSurface,
        indicatorColor: ColorConstants.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? ColorConstants.accent
                : ColorConstants.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? ColorConstants.accent
                : ColorConstants.lightTextSecondary,
          );
        }),
      ),
    );
  }
}
