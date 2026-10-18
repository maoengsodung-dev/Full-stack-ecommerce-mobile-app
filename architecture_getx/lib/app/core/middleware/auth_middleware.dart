import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Guards all protected routes (Shell, Product Detail, Cart, etc.)
/// Redirects to /login if there is no auth token in storage.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (!storage.hasToken) {
      return const RouteSettings(name: Routes.AUTH);
    }
    return null; // allow navigation
  }
}

/// Guards auth routes (/login, /register).
/// If already logged in, redirect to Shell.
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (storage.hasToken) {
      return const RouteSettings(name: Routes.SHELL);
    }
    return null; // allow navigation
  }
}

/// Guards admin routes (/admin-page, /add-product).
/// Requires a valid token AND the admin flag, otherwise redirects.
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (!storage.hasToken) {
      return const RouteSettings(name: Routes.AUTH);
    }
    final user = storage.getUser();
    final hasAdmin = storage.isAdmin ||
        user?.roles?.contains('admin') == true ||
        storage.getActiveRole().toLowerCase() == 'admin';
    if (!hasAdmin) {
      return const RouteSettings(name: Routes.SHELL);
    }
    return null; // allow navigation
  }
}
