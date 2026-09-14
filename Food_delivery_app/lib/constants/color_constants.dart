import 'package:flutter/material.dart';

class ColorConstants {
  ColorConstants._();

  static bool _dark = true;

  static bool get isDark => _dark;

  static void applyDark(bool value) => _dark = value;

  static const accent = Color(0xffe85d4c);
  static const accentMuted = Color(0xffc0392b);
  static const accentSoft = Color(0x33e85d4c);
  static const gold = Color(0xffd4af37);
  static const goldDeep = Color(0xffa9842a);
  static const goldSoft = Color(0x33d4af37);
  static const cream = Color(0xfff6f1ea);
  static const star = Color(0xffe8c547);
  static const success = Color(0xff2fa36b);
  static const warning = Color(0xfff0a202);
  static const error = Color(0xffe85d4c);
  static const white = Color(0xffffffff);
  static const veg = Color(0xff2fa36b);
  static const nonVeg = Color(0xffc0392b);

  static const darkBackground = Color(0xff0b0a09);
  static const darkSurface = Color(0xff141210);
  static const darkCard = Color(0xff1c1814);
  static const darkCardElevated = Color(0xff241f1a);
  static const darkBorder = Color(0x22FFFFFF);
  static const darkText = Color(0xfff6f1ea);
  static const darkTextSecondary = Color(0xffb8aea3);
  static const darkTextMuted = Color(0xff7d746b);
  static const darkOverlay = Color(0xCC000000);
  static const darkToaster = Color(0xff241f1a);

  static const lightBackground = Color(0xfff6f3ee);
  static const lightSurface = Color(0xffffffff);
  static const lightCard = Color(0xffffffff);
  static const lightCardElevated = Color(0xfffffdf9);
  static const lightBorder = Color(0x14000000);
  static const lightText = Color(0xff1c1917);
  static const lightTextSecondary = Color(0xff6b645c);
  static const lightTextMuted = Color(0xff9a928a);
  static const lightOverlay = Color(0x66000000);
  static const lightToaster = Color(0xff2a2520);

  static Color get background => _dark ? darkBackground : lightBackground;
  static Color get surface => _dark ? darkSurface : lightSurface;
  static Color get card => _dark ? darkCard : lightCard;
  static Color get cardElevated => _dark ? darkCardElevated : lightCardElevated;
  static Color get cardBorder => _dark ? darkBorder : lightBorder;
  static Color get textPrimary => _dark ? darkText : lightText;
  static Color get textSecondary =>
      _dark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => _dark ? darkTextMuted : lightTextMuted;
  static Color get overlay => _dark ? darkOverlay : lightOverlay;
  static Color get toasterBg => _dark ? darkToaster : lightToaster;

  static LinearGradient get headerGradient => _dark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff2a1610), Color(0xff0b0a09)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffffe8dc), Color(0xfff6f3ee)],
        );

  static LinearGradient get goldGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfff0d78c), gold, goldDeep],
      );

  static LinearGradient get buttonGradient => const LinearGradient(
        colors: [accent, accentMuted],
      );

  static LinearGradient get imageScrim => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          _dark ? const Color(0xCC0B0A09) : const Color(0x990B0A09),
        ],
      );
}
