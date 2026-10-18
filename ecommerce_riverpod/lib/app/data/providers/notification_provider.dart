import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';
import 'package:dio/dio.dart';


final notificationDataProvider = Provider<NotificationProvider>((ref) {
  return NotificationProvider(ref.watch(apiClientProvider));
});

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
        if (deviceId != null) 'device_id': deviceId,
        if (appVersion != null) 'app_version': appVersion,
      },
    );
  }
}
