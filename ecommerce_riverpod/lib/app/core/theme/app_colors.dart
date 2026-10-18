import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF3F3F7);// Deep indigo
  static const Color primary = Color(0xFF4338CA); // Indigo
  static const Color accent = Color(0xFFFF6B6B); // Coral
  static const Color accentLight = Color(0xFFFFE4E4); // Light coral
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E); // Dark navy
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textHint = Color(0xFFADB5BD); // Light gray
  static const Color iconPrimary = Color(0xFF1A1A2E);
  static const Color iconSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusShipped = Color(0xFF8B5CF6);
  static const Color statusDelivered = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  static const Color authPurple = Color(0xFF9E86FC);
  static const Color authPurpleDark = Color(0xFF8B6EF6);
  static const Color authPurpleLight = Color(0xFFB8A5FF);
  static const Color authFieldFill = Color(0xFFF7F8FA);
  static const Color authFieldBorder = Color(0xFFE8E9EE);
  static const Color authTabBg = Color(0xFFF4F5F9);

  static const Color darkPill = Color(0xFF1E293B);
  static const Color neonLime = Color(0xFFD4FC34);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color softGrey = Color(0xFFF1F5F9);
  static const Color pageBg = Color(0xFFF8FAFC);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF64748B);

  static const LinearGradient gradient = LinearGradient(
    colors: [primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient authGradient = LinearGradient(
    colors: [Color(0xFF9E86FC), Color(0xFF8B6EF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
