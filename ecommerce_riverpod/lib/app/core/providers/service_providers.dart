import 'package:architecture_getx/app/core/providers/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/image_picker_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';


final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return NotificationService(storage);
});
