import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/providers/core_providers.dart';
import '../../../../app/data/models/user.model.dart';
import '../../../../app/data/models/user_role.dart';
import '../../../../app/data/repository/auth_repository.dart';
import '../../../../app/core/providers/storage_providers.dart';

class AuthState {
  final AsyncValue<UserModel?> user;
  final AsyncValue<void> actionState;
  final bool isLoginTab;
  final bool rememberMe;
  final bool isPasswordVisible;
  final bool isRegPasswordVisible;
  final bool isRegConfirmPasswordVisible;

  const AuthState({
    this.user = const AsyncValue.data(null),
    this.actionState = const AsyncValue.data(null),
    this.isLoginTab = true,
    this.rememberMe = false,
    this.isPasswordVisible = false,
    this.isRegPasswordVisible = false,
    this.isRegConfirmPasswordVisible = false,
  });

  bool get isLoading => actionState.isLoading;

  AuthState copyWith({
    AsyncValue<UserModel?>? user,
    AsyncValue<void>? actionState,
    bool? isLoginTab,
    bool? rememberMe,
    bool? isPasswordVisible,
    bool? isRegPasswordVisible,
    bool? isRegConfirmPasswordVisible,
  }) {
    return AuthState(
      user: user ?? this.user,
      actionState: actionState ?? this.actionState,
      isLoginTab: isLoginTab ?? this.isLoginTab,
      rememberMe: rememberMe ?? this.rememberMe,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isRegPasswordVisible:
          isRegPasswordVisible ?? this.isRegPasswordVisible,
      isRegConfirmPasswordVisible:
          isRegConfirmPasswordVisible ?? this.isRegConfirmPasswordVisible,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const String _adminEmail = 'admin@example.com';
  static const String _adminPassword = 'Admin123!';

  @override
  AuthState build() {
    final storage = ref.watch(storageServiceProvider);
    final cachedUser = storage.getUser();
    return AuthState(
      user: AsyncValue.data(cachedUser),
    );
  }

  void setAuthTab(bool isLogin) {
    state = state.copyWith(isLoginTab: isLogin);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleRegPasswordVisibility() {
    state = state.copyWith(
      isRegPasswordVisible: !state.isRegPasswordVisible,
    );
  }

  void toggleRegConfirmPasswordVisibility() {
    state = state.copyWith(
      isRegConfirmPasswordVisible: !state.isRegConfirmPasswordVisible,
    );
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  String _extractToken(dynamic data) {
    if (data == null) return '';
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
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
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v is Map) {
          final nestedToken = _extractToken(v);
          if (nestedToken.isNotEmpty) return nestedToken;
        }
      }
      if (data['data'] != null) {
        final nestedToken = _extractToken(data['data']);
        if (nestedToken.isNotEmpty) return nestedToken;
      }
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

  Map<String, dynamic>? _extractUser(dynamic data) {
    if (data == null || data is! Map) return null;
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }
    if (data['data'] is Map) {
      final nested = data['data'] as Map;
      if (nested['user'] is Map) {
        return Map<String, dynamic>.from(nested['user'] as Map);
      }
      if (nested.containsKey('email') ||
          (nested.containsKey('name') && nested.containsKey('id'))) {
        return Map<String, dynamic>.from(nested);
      }
    }
    if (data.containsKey('email') &&
        (data.containsKey('name') || data.containsKey('id'))) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<bool> login(String email, String password, {bool? forceAdmin}) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final repo = ref.read(authRepositoryProvider);
      final storage = ref.read(storageServiceProvider);

      final data = await repo.login(email.trim(), password);
      final token = _extractToken(data);
      if (token.isEmpty) {
        state = state.copyWith(
          actionState: AsyncValue.error(
            'Server returned success, but no access token was found in the response.',
            StackTrace.current,
          ),
        );
        return false;
      }

      await storage.saveToken(token);

      UserModel? u;
      final userData = _extractUser(data);
      if (userData != null) {
        try {
          u = UserModel.fromJson(userData);
        } catch (_) {}
      }

      if (u == null || (u.data?.user?.name?.isEmpty ?? true)) {
        try {
          u = await repo.getProfile();
        } catch (_) {}
      }

      if (u != null) {
        await storage.saveUser(u);
        state = state.copyWith(user: AsyncValue.data(u));
      }

      final roles = u?.data?.user?.roles ?? u?.user?.roles ?? [];
      final hasAdminRole = roles.any((r) => r.toLowerCase().contains('admin'));
      final isEmailAdmin =
          email.trim().toLowerCase() == _adminEmail.toLowerCase() ||
          email.trim().toLowerCase().startsWith('admin@') ||
          (email.trim() == _adminEmail && password == _adminPassword);
      final isRawAdmin = (userData != null && (
          userData['role']?.toString().toLowerCase().contains('admin') == true ||
          userData['is_admin'] == true ||
          userData['is_admin'] == 1 ||
          userData['isAdmin'] == true
      )) || (
          data['role']?.toString().toLowerCase().contains('admin') == true ||
          data['is_admin'] == true ||
          data['is_admin'] == 1 ||
          data['isAdmin'] == true
      );

      final isAdmin = forceAdmin == true ||
          hasAdminRole ||
          isEmailAdmin ||
          isRawAdmin ||
          (u?.isAdmin == true);

      await storage.saveIsAdmin(isAdmin);
      await storage.saveActiveRole(isAdmin ? 'admin' : 'customer');
      if (isAdmin) {
        await storage.saveAdminToken(token);
        ref.read(activeRoleProvider.notifier).setRole(UserRole.admin);
      } else {
        await storage.removeAdminToken();
        ref.read(activeRoleProvider.notifier).setRole(UserRole.customer);
      }

      _registerDeviceTokenSafely();
      state = state.copyWith(actionState: const AsyncValue.data(null));
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          'Login failed. Check your credentials.';
      state = state.copyWith(
        actionState: AsyncValue.error(msg, StackTrace.current),
      );
      return false;
    } catch (e, st) {
      state = state.copyWith(
        actionState: AsyncValue.error(e.toString(), st),
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final repo = ref.read(authRepositoryProvider);
      final storage = ref.read(storageServiceProvider);
      final fullName = '$firstName $lastName'.trim();

      final data = await repo.register(
        name: fullName,
        email: email.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final token = _extractToken(data);
      if (token.isNotEmpty) {
        await storage.saveToken(token);
      }

      UserModel? u;
      final userData = _extractUser(data);
      if (userData != null) {
        try {
          u = UserModel.fromJson(userData);
        } catch (_) {}
      }

      if (token.isNotEmpty &&
          (u == null || (u.data?.user?.name?.isEmpty ?? true))) {
        try {
          u = await repo.getProfile();
        } catch (_) {}
      }

      if (u != null) {
        await storage.saveUser(u);
        state = state.copyWith(user: AsyncValue.data(u));
      }

      state = state.copyWith(actionState: const AsyncValue.data(null));
      return true;
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      String msg;
      if (errors is Map) {
        final firstErrors = errors.values.first;
        msg = firstErrors is List
            ? firstErrors.first.toString()
            : firstErrors.toString();
      } else {
        msg = e.response?.data?['message'] ?? 'Registration failed';
      }
      state = state.copyWith(
        actionState: AsyncValue.error(msg, StackTrace.current),
      );
      return false;
    } catch (e, st) {
      state = state.copyWith(
        actionState: AsyncValue.error(e.toString(), st),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (_) {}
    final storage = ref.read(storageServiceProvider);
    await storage.clearAll();
    ref.read(activeRoleProvider.notifier).setRole(UserRole.customer);
    state = const AuthState();
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(email.trim());
      state = state.copyWith(actionState: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(
        actionState: AsyncValue.error(e.toString(), st),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(actionState: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(
        actionState: AsyncValue.error(e.toString(), st),
      );
      return false;
    }
  }

  Future<void> _registerDeviceTokenSafely() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        final repo = ref.read(authRepositoryProvider);
        await repo.registerDeviceToken(
          token: token,
          platform: 'android',
          appVersion: '1.0.0',
        );
      }
    } catch (_) {}
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
