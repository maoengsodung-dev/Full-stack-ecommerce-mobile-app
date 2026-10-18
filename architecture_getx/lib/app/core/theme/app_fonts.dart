import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  static bool get isKhmer =>
      (Get.locale?.languageCode ?? '').toLowerCase() == 'km';

  static String? get currentFontFamily =>
      isKhmer ? GoogleFonts.battambang().fontFamily : GoogleFonts.inter().fontFamily;

  static List<String> get currentFontFamilyFallback {
    final fallback = isKhmer
        ? (GoogleFonts.inter().fontFamily ?? 'Inter')
        : (GoogleFonts.battambang().fontFamily ?? 'Battambang');
    return [fallback];
  }

  static TextStyle battambang({TextStyle? textStyle, Color? color, double? fontSize, FontWeight? fontWeight}) =>
      GoogleFonts.battambang(textStyle: textStyle, color: color, fontSize: fontSize, fontWeight: fontWeight);

  static TextStyle inter({TextStyle? textStyle, Color? color, double? fontSize, FontWeight? fontWeight}) =>
      GoogleFonts.inter(textStyle: textStyle, color: color, fontSize: fontSize, fontWeight: fontWeight);

  /// Returns dynamic Google font: Inter for English and Battambang for Khmer
  static TextStyle font({
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
    if (isKhmer) {
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

  /// Drop-in compatibility alias that routes to dynamic Google Font (Inter / Battambang)
  static TextStyle poppins({
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
    return font(
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
