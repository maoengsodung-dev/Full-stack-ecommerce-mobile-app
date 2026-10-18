import '../models/user.model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider;

  AuthRepository(this._provider);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _provider.login(email, password);
    final raw = response.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{'data': raw};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _provider.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
    );
    final raw = response.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{'data': raw};
  }

  Future<void> logout() async {
    await _provider.logout();
  }

  Future<UserModel> getProfile() async {
    final response = await _provider.getProfile();
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _provider.updateProfile(data);
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> uploadAvatar(String filePath) async {
    final response = await _provider.uploadAvatar(filePath);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    return getProfile();
  }

  Future<dynamic> forgotPassword(String email) async {
    final response = await _provider.forgotPassword(email);
    return response.data;
  }

  Future<dynamic> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _provider.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return response.data;
  }

  Future<dynamic> refreshToken() async {
    final response = await _provider.refreshToken();
    return response.data;
  }

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
    String? deviceId,
  }) async {
    await _provider.registerDeviceToken(
      token: token,
      platform: platform,
      appVersion: appVersion,
      deviceId: deviceId,
    );
  }

  Future<void> deregisterDeviceToken(String token) async {
    await _provider.deregisterDeviceToken(token);
  }
}

