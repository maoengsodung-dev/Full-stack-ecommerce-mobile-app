import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class NotificationProvider {
  final ApiClient _apiClient;

  NotificationProvider(this._apiClient);

  /// Fetches notifications from backend (`GET /notifications`)
  Future<Response> getNotifications() async {
    return await _apiClient.get(kNotifications);
  }

  /// Registers FCM device token with backend (`POST /device-tokens`)
  Future<Response> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
    String? appVersion,
  }) async {
    return await _apiClient.post(
      kDeviceTokens,
      data: {
        'token': token,
        'platform': platform,
        'device_id': ?deviceId,
        'app_version': ?appVersion,
      },
    );
  }
}
