import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/user.model.dart';
import 'package:architecture_getx/app/data/repository/auth_repository.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static const String _adminEmail = 'admin@example.com';
  static const String _adminPassword = 'Admin123!';

  final AuthRepository _repo;
  final StorageService _storage;

  AuthController(this._repo, this._storage);

  // ── Observables ─────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSendingReset = false.obs;
  final user = Rxn<UserModel>();
  final isLoginTab = true.obs;

  void setAuthTab(bool isLogin) {
    unfocusAll();
    isLoginTab.value = isLogin;
  }

  void unfocusAll() {
    loginEmailFocusNode.unfocus();
    loginPasswordFocusNode.unfocus();
    regFirstNameFocusNode.unfocus();
    regLastNameFocusNode.unfocus();
    regEmailFocusNode.unfocus();
    regPasswordFocusNode.unfocus();
    regConfirmFocusNode.unfocus();
  }

  // ── Login form ───────────────────────────────────────────────────────────────
  final loginEmailCtrl = TextEditingController();
  final loginPasswordCtrl = TextEditingController();
  final loginEmailFocusNode = FocusNode();
  final loginPasswordFocusNode = FocusNode();
  final loginFormKey = GlobalKey<FormState>();
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;

  // ── Register form ────────────────────────────────────────────────────────────
  final regFirstNameCtrl = TextEditingController();
  final regLastNameCtrl = TextEditingController();
  final regEmailCtrl = TextEditingController();
  final regPasswordCtrl = TextEditingController();
  final regConfirmCtrl = TextEditingController();

  final regFirstNameFocusNode = FocusNode();
  final regLastNameFocusNode = FocusNode();
  final regEmailFocusNode = FocusNode();
  final regPasswordFocusNode = FocusNode();
  final regConfirmFocusNode = FocusNode();
  final regFormKey = GlobalKey<FormState>();
  final isRegPasswordVisible = false.obs;
  final isRegConfirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load cached user data for display (if coming back to login while cached)
    user.value = _storage.getUser();
  }

  // ── Helper: Extract Token from any Laravel API structure ───────────────────

  String _extractToken(dynamic data) {
    if (data == null) return '';

    // If data itself is a token string
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map) {
      // 1. Direct top-level keys
      final tokenKeys = [
        'token',
        'access_token',
        'plainTextToken',
        'api_token',
        'bearer_token',
        'jwt',
        'key',
      ];

      for (final k in tokenKeys) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) {
          return v.trim();
        }
        if (v is Map) {
          final nestedToken = _extractToken(v);
          if (nestedToken.isNotEmpty) return nestedToken;
        }
      }

      // 2. Nested in 'data' wrapper
      if (data['data'] != null) {
        final nestedToken = _extractToken(data['data']);
        if (nestedToken.isNotEmpty) return nestedToken;
      }

      // 3. Nested in 'authorisation' / 'authorization' / 'result' / 'response'
      for (final wrapper in [
        'authorisation',
        'authorization',
        'result',
        'response',
        'payload',
      ]) {
        if (data[wrapper] != null) {
          final nestedToken = _extractToken(data[wrapper]);
          if (nestedToken.isNotEmpty) return nestedToken;
        }
      }
    }

    return '';
  }

  // ── Helper: Extract User Map from response ─────────────────────────────────

  Map<String, dynamic>? _extractUser(dynamic data) {
    if (data == null || data is! Map) return null;

    // 1. Direct 'user' key
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }

    // 2. Inside 'data'
    if (data['data'] is Map) {
      final nested = data['data'] as Map;
      if (nested['user'] is Map) {
        return Map<String, dynamic>.from(nested['user'] as Map);
      }
      // If 'data' map is the user object itself
      if (nested.containsKey('email') ||
          (nested.containsKey('name') && nested.containsKey('id'))) {
        return Map<String, dynamic>.from(nested);
      }
    }

    // 3. Top-level map has user properties
    if (data.containsKey('email') &&
        (data.containsKey('name') || data.containsKey('id'))) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  // ── Login ────────────────────────────────────────────────────────────────────

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      final data = await _repo.login(
        loginEmailCtrl.text.trim(),
        loginPasswordCtrl.text,
      );

      debugPrint('==> Login Response: $data');

      final token = _extractToken(data);
      if (token.isEmpty) {
        Get.snackbar(
          'Login Error',
          'Server returned success, but no access token was found in the response.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF5350),
          colorText: const Color(0xFFFFFFFF),
        );
        return;
      }

      // Save token first so interceptor can use it for subsequent calls
      await _storage.saveToken(token);

      // Parse user from response or fallback to getProfile()
      UserModel? u;
      final userData = _extractUser(data);
      if (userData != null) {
        try {
          u = UserModel.fromJson(userData);
        } catch (e) {
          debugPrint('Error parsing user from login response: $e');
        }
      }

      // If user profile is missing or incomplete, fetch via /auth/profile
      if (u == null || (u.data?.user?.name?.isEmpty ?? true)) {
        try {
          u = await _repo.getProfile();
        } catch (e) {
          debugPrint('Could not fetch profile after login: $e');
        }
      }

      if (u != null) {
        user.value = u;
        await _storage.saveUser(u);
      }

      final roles = u?.data?.user?.roles ?? [];
      final isAdmin = roles.contains('admin') ||
          (loginEmailCtrl.text.trim() == _adminEmail &&
              loginPasswordCtrl.text == _adminPassword);
      await _storage.saveIsAdmin(isAdmin);
      await _storage.saveActiveRole(isAdmin ? 'admin' : 'customer');
      if (isAdmin) {
        await _storage.saveAdminToken(token);
      }

      _registerDeviceTokenSafely();

      if (isAdmin) {
        Get.offAllNamed(Routes.ADMIN);
      } else {
        Get.offAllNamed(Routes.SHELL);
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          'Login failed. Check your credentials.';
      Get.snackbar(
        'Login Failed',
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────────

  Future<void> register() async {
    if (!regFormKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      final firstName = regFirstNameCtrl.text.trim();
      final lastName = regLastNameCtrl.text.trim();
      final fullName = '$firstName $lastName'.trim();

      final data = await _repo.register(
        name: fullName,
        email: regEmailCtrl.text.trim(),
        password: regPasswordCtrl.text,
        passwordConfirmation: regConfirmCtrl.text,
      );

      debugPrint('==> Register Response: $data');

      final token = _extractToken(data);
      if (token.isNotEmpty) {
        await _storage.saveToken(token);
      }

      UserModel? u;
      final userData = _extractUser(data);
      if (userData != null) {
        try {
          u = UserModel.fromJson(userData);
        } catch (e) {
          debugPrint('Error parsing user from register response: $e');
        }
      }

      // If registered with token, try fetching profile if user was empty
      if (token.isNotEmpty &&
          (u == null || (u.data?.user?.name?.isEmpty ?? true))) {
        try {
          u = await _repo.getProfile();
        } catch (e) {
          debugPrint('Could not fetch profile after register: $e');
        }
      }

      if (u != null) {
        user.value = u;
        await _storage.saveUser(u);
      }

      Get.offAllNamed(Routes.SHELL);
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      if (errors is Map) {
        final firstErrors = errors.values.first;
        final msg = firstErrors is List
            ? firstErrors.first.toString()
            : firstErrors.toString();
        Get.snackbar(
          'Validation Error',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF5350),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        final msg = e.response?.data?['message'] ?? 'Registration failed';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF5350),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await _storage.clearAll();
    user.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> _registerDeviceTokenSafely() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _repo.registerDeviceToken(
          token: token,
          platform: 'android',
          appVersion: '1.0.0',
        );
      }
    } catch (_) {}
  }

  // ── Forgot Password ──────────────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    if (email.trim().isEmpty || !GetUtils.isEmail(email.trim())) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
      return false;
    }
    try {
      isSendingReset.value = true;
      final res = await _repo.forgotPassword(email.trim());
      final msg = res is Map
          ? (res['message'] ?? 'Password reset link sent to your email.')
          : 'Password reset link sent.';
      Get.snackbar(
        'Success',
        msg.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to send reset link';
      Get.snackbar(
        'Error',
        msg.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSendingReset.value = false;
    }
  }

  // ── Reset Password ───────────────────────────────────────────────────────────

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isSendingReset.value = true;
      final res = await _repo.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final msg = res is Map
          ? (res['message'] ?? 'Password successfully reset.')
          : 'Password reset.';
      Get.snackbar(
        'Success',
        msg.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to reset password';
      Get.snackbar(
        'Error',
        msg.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSendingReset.value = false;
    }
  }

  @override
  void onClose() {
    loginEmailCtrl.dispose();
    loginPasswordCtrl.dispose();
    loginEmailFocusNode.dispose();
    loginPasswordFocusNode.dispose();
    regFirstNameCtrl.dispose();
    regLastNameCtrl.dispose();
    regEmailCtrl.dispose();
    regPasswordCtrl.dispose();
    regConfirmCtrl.dispose();
    regFirstNameFocusNode.dispose();
    regLastNameFocusNode.dispose();
    regEmailFocusNode.dispose();
    regPasswordFocusNode.dispose();
    regConfirmFocusNode.dispose();
    super.onClose();
  }
}
