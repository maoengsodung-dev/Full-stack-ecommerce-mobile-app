import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class AuthProvider {
  final ApiClient _apiClient;

  AuthProvider(this._apiClient);

  Future<Response> login(String email, String password) async {
    return await _apiClient.post(kLogin, data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    return await _apiClient.post(kRegister, data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
  }

  Future<Response> logout() async {
    return await _apiClient.post(kLogout);
  }

  Future<Response> getProfile() async {
    return await _apiClient.get(kProfile);
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.put(kProfile, data: data);
  }

  Future<Response> uploadAvatar(String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
      '_method': 'PUT',
    });
    return await _apiClient.post(kProfile, data: formData);
  }

  Future<Response> forgotPassword(String email) async {
    return await _apiClient.post(kForgotPassword, data: {
      'email': email.trim(),
    });
  }

  Future<Response> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiClient.post(kResetPassword, data: {
      'token': token.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> refreshToken() async {
    return await _apiClient.post(kRefreshToken);
  }

  Future<Response> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
    String? deviceId,
  }) async {
    return await _apiClient.post(kDeviceTokens, data: {
      'token': token,
      'platform': platform,
      'app_version': ?appVersion,
      'device_id': ?deviceId,
    });
  }

  Future<Response> deregisterDeviceToken(String token) async {
    return await _apiClient.delete(kDeviceTokens, data: {
      'token': token,
    });
  }
}

