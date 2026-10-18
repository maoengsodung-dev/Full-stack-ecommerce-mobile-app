import 'package:flutter/material.dart';

enum AppLanguage {
  english(
    'en',
    'English',
    'English',
    '🇬🇧',
    Color(0xFFE3F2FD),
    Color(0xFF1976D2),
  ),
  khmer(
    'km',
    'Khmer',
    'ភាសាខ្មែរ',
    '🇰🇭',
    Color(0xFFE8F5E9),
    Color(0xFF2E7D32),
  ),
  japanese(
    'ja',
    'Japanese',
    '日本語',
    '🇯🇵',
    Color(0xFFFCE4EC),
    Color(0xFFC2185B),
  ),
  korean(
    'ko',
    'Korean',
    '한국어',
    '🇰🇷',
    Color(0xFFEDE7F6),
    Color(0xFF512DA8),
  ),
  vietnamese(
    'vi',
    'Vietnamese',
    'Tiếng Việt',
    '🇻🇳',
    Color(0xFFFFF3E0),
    Color(0xFFE65100),
  ),
  chinese(
    'zh',
    'Chinese',
    '中文',
    '🇨🇳',
    Color(0xFFFFEBEE),
    Color(0xFFC62828),
  );

  final String code;
  final String displayName;
  final String nativeName;
  final String flag;
  final Color badgeColor;
  final Color textColor;

  const AppLanguage(
    this.code,
    this.displayName,
    this.nativeName,
    this.flag,
    this.badgeColor,
    this.textColor,
  );

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    final cleanCode = code.toLowerCase().trim();
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == cleanCode,
      orElse: () => AppLanguage.english,
    );
  }

  Locale get locale => Locale(code);
}
