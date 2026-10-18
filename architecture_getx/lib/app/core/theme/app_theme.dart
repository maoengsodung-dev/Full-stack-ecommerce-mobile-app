import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const background = Color(
    0xFFF3F3F7,
  ); // Off-white blue// Off-white blue
  static const primary = Color(0xFF1E1B4B); // Deep indigo
  static const primaryLight = Color(0xFF4338CA); // Indigo
  static const accent = Color(0xFFFF6B6B); // Coral
  static const accentLight = Color(0xFFFFE4E4); // Light coral
  static const surface = Colors.white;
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E); // Dark navy
  static const textSecondary = Color(0xFF6B7280); // Gray
  static const textHint = Color(0xFFADB5BD); // Light gray
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444); // Red
  static const divider = Color(0xFFE5E7EB);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);

  static const statusPending = Color(0xFFF59E0B);
  static const statusProcessing = Color(0xFF3B82F6);
  static const statusShipped = Color(0xFF8B5CF6);
  static const statusDelivered = Color(0xFF10B981);
  static const statusCancelled = Color(0xFFEF4444);
  static const authPurple = Color(0xFF9E86FC);
  static const authPurpleDark = Color(0xFF8B6EF6);
  static const authPurpleLight = Color(0xFFB8A5FF);
  static const authFieldFill = Color(0xFFF7F8FA);
  static const authFieldBorder = Color(0xFFE8E9EE);
  static const authTabBg = Color(0xFFF4F5F9);
  static const Color darkPill = Color(0xFF1E293B);
  static const Color neonLime = Color(0xFFD4FC34);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color pageBg = Color(0xFFF8FAFC);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);


  static const gradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const authGradient = LinearGradient(
    colors: [Color(0xFF9E86FC), Color(0xFF8B6EF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData getTheme([String? languageCode]) {
    final currentCode = languageCode ??
        (Get.isRegistered<StorageService>()
            ? Get.find<StorageService>().getLanguage()
            : null) ??
        Get.locale?.languageCode;
    final isKhmer = (currentCode ?? '').toLowerCase() == 'km';
    final textThemeBuilder =
        isKhmer ? GoogleFonts.battambangTextTheme : GoogleFonts.interTextTheme;
    final fontStyle = isKhmer ? GoogleFonts.battambang : GoogleFonts.inter;
    final fontFamily = isKhmer
        ? GoogleFonts.battambang().fontFamily
        : GoogleFonts.inter().fontFamily;
    final fallbackFamily = isKhmer
        ? (GoogleFonts.inter().fontFamily ?? 'Inter')
        : (GoogleFonts.battambang().fontFamily ?? 'Battambang');

    final textTheme = textThemeBuilder(ThemeData.light().textTheme)
        .apply(
          fontFamily: fontFamily,
          fontFamilyFallback: [fallbackFamily],
        )
        .copyWith(
          displayLarge: fontStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          headlineMedium: fontStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: fontStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: fontStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          bodyMedium: fontStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.divider,
        centerTitle: false,
        titleTextStyle: fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: fontStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: fontStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: fontStyle(fontSize: 14, color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: fontStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: fontStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get light => getTheme();
}
