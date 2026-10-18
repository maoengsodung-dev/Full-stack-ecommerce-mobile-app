import 'package:flutter/material.dart';
import '../../routes/app_pages.dart';

enum UserRole {
  customer,
  admin;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    switch (role.trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String get value => name;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Control tower, products, categories & orders';
      case UserRole.customer:
        return 'Shopping store, product catalog & cart';
    }
  }

  String get route {
    switch (this) {
      case UserRole.admin:
        return Routes.ADMIN;
      case UserRole.customer:
        return Routes.SHELL;
    }
  }

  Color get badgeColor {
    switch (this) {
      case UserRole.admin:
        return const Color(0xFFFDE8E8);
      case UserRole.customer:
        return const Color(0xFFE3F2FD);
    }
  }

  Color get textColor {
    switch (this) {
      case UserRole.admin:
        return const Color(0xFFC81E1E);
      case UserRole.customer:
        return const Color(0xFF1D4ED8);
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.customer:
        return Icons.person_rounded;
    }
  }
}
