import 'package:dio/dio.dart';
import '../../../../app/data/providers/auth_provider.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> login(String email, String password);
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<dynamic> logout();
  Future<dynamic> getProfile();
  Future<dynamic> refreshToken();
  Future<dynamic> forgotPassword(String email);
  Future<dynamic> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<dynamic> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
    String? appVersion,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthProvider _provider;

  AuthRemoteDataSourceImpl(this._provider);

  @override
  Future<dynamic> login(String email, String password) async {
    final response = await _provider.login(email, password);
    return response.data;
  }

  @override
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _provider.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return response.data;
  }

  @override
  Future<dynamic> logout() async {
    final response = await _provider.logout();
    return response.data;
  }

  @override
  Future<dynamic> getProfile() async {
    final response = await _provider.getProfile();
    return response.data;
  }

  @override
  Future<dynamic> refreshToken() async {
    final response = await _provider.refreshToken();
    return response.data;
  }

  @override
  Future<dynamic> forgotPassword(String email) async {
    final response = await _provider.forgotPassword(email);
    return response.data;
  }

  @override
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

  @override
  Future<dynamic> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
    String? appVersion,
  }) async {
    final response = await _provider.registerDeviceToken(
      token: token,
      platform: platform,
      deviceId: deviceId,
      appVersion: appVersion,
    );
    return response.data;
  }
}
