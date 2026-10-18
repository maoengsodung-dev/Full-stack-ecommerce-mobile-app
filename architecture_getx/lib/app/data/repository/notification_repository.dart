import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationRepository {
  final NotificationProvider _provider;

  NotificationRepository(this._provider);

  /// Retrieves list of notifications from backend
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _provider.getNotifications();
      final rawData = response.data;
      final List data;
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        data = rawData['data'] as List;
      } else {
        data = [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Registers device token with backend
  Future<bool> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
    String? appVersion,
  }) async {
    try {
      final response = await _provider.registerDeviceToken(
        token: token,
        platform: platform,
        deviceId: deviceId,
        appVersion: appVersion,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
