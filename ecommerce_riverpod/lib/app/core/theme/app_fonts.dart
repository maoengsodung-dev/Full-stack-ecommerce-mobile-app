import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../router/app_router.dart';

class AppFonts {
  AppFonts._();

  static bool isKhmerLocale([BuildContext? context]) {
    final ctx = context ?? AppRouter.navigatorKey.currentContext;
    if (ctx != null) {
      final locale = Localizations.maybeLocaleOf(ctx);
      return (locale?.languageCode ?? '').toLowerCase() == 'km';
    }
    return false;
  }

  static bool get isKhmer => isKhmerLocale();

  static String? get currentFontFamily =>
      isKhmer ? GoogleFonts.battambang().fontFamily : GoogleFonts.inter().fontFamily;

  static List<String> get currentFontFamilyFallback {
    final fallback = isKhmer
        ? (GoogleFonts.inter().fontFamily ?? 'Inter')
        : (GoogleFonts.battambang().fontFamily ?? 'Battambang');
    return [fallback];
  }

  static TextStyle battambang({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      GoogleFonts.battambang(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );

  static TextStyle inter({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      GoogleFonts.inter(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );

  /// Returns dynamic Google font: Inter for English and Battambang for Khmer
  static TextStyle font({
    BuildContext? context,
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    if (isKhmerLocale(context)) {
      return GoogleFonts.battambang(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }

    return GoogleFonts.inter(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}
