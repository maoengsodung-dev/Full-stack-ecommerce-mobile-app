import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle getDisplayLarge({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle getHeadlineMedium({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle getTitleLarge({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle getBodyLarge({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 14,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle getBodyMedium({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 12,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle getCaption({bool? isKhmer, Color? color}) {
    final style = (isKhmer ?? AppFonts.isKhmer) ? GoogleFonts.battambang : GoogleFonts.inter;
    return style(
      fontSize: 11,
      color: color ?? AppColors.textHint,
    );
  }

  static TextStyle get displayLarge => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 11,
        color: AppColors.textHint,
      );
}
