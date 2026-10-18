import 'dart:convert';

import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/notification_model.dart';
import 'package:architecture_getx/app/data/repository/notification_repository.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef NotificationItem = NotificationModel;

class NotificationController extends GetxController {
  final NotificationRepository? _repository;
  final StorageService? _storageService;

  NotificationController({
    NotificationRepository? repository,
    StorageService? storageService,
  })  : _repository = repository ??
            (Get.isRegistered<NotificationRepository>()
                ? Get.find<NotificationRepository>()
                : null),
        _storageService = storageService ??
            (Get.isRegistered<StorageService>()
                ? Get.find<StorageService>()
                : null);

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadCachedNotifications();
    fetchNotifications();
  }

  void _loadCachedNotifications() {
    try {
      final rawList = _storageService?.getNotificationsRaw() ?? [];
      if (rawList.isNotEmpty) {
        final cached = rawList.map((str) {
          final json = jsonDecode(str) as Map<String, dynamic>;
          return NotificationModel.fromJson(json);
        }).toList();
        notifications.assignAll(cached);
      }
    } catch (e) {
      debugPrint('[NotificationController] loadCached error: $e');
    }
  }

  Future<void> fetchNotifications() async {
    if (_repository == null) return;
    try {
      isLoading.value = true;
      final serverItems = await _repository.getNotifications();
      if (serverItems.isNotEmpty) {
        // Merge with local notifications without losing isRead status
        final existingMap = {for (final n in notifications) n.id: n};
        for (final s in serverItems) {
          if (existingMap.containsKey(s.id)) {
            s.isRead = existingMap[s.id]!.isRead;
          }
        }

        // Add any local items that aren't on server (e.g. recent FCM)
        final serverIds = serverItems.map((e) => e.id).toSet();
        final localOnly =
            notifications.where((n) => !serverIds.contains(n.id)).toList();

        final merged = [...localOnly, ...serverItems];
        merged.sort((a, b) => b.time.compareTo(a.time));
        notifications.assignAll(merged);
        _saveToCache();
      }
    } catch (e) {
      debugPrint('[NotificationController] fetchNotifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addNotification(NotificationModel item) {
    // Avoid duplicate IDs
    notifications.removeWhere((n) => n.id == item.id);
    notifications.add(item);
    notifications.sort((a, b) => b.time.compareTo(a.time));
    _saveToCache();
  }

  void onNotificationTapped(NotificationModel item) {
    markAsRead(item.id);

    final slug = item.productSlug;
    final productId = item.productId;

    if (item.type == 'product' || item.data?['event'] == 'new_product') {
      if (slug != null && slug.isNotEmpty) {
        Get.toNamed(Routes.PRODUCT_DETAIL, arguments: slug);
        return;
      } else if (productId != null && productId.isNotEmpty) {
        final idInt = int.tryParse(productId);
        Get.toNamed(Routes.PRODUCT_DETAIL, arguments: idInt ?? productId);
        return;
      }
    }

    if (item.type == 'promo' || item.data?['event'] == 'new_promotion') {
      // If banner points to a product
      final linkType = item.data?['link_type']?.toString();
      final linkId = item.data?['link_id']?.toString();
      if (linkType == 'product' && linkId != null && linkId.isNotEmpty) {
        final idInt = int.tryParse(linkId);
        Get.toNamed(Routes.PRODUCT_DETAIL, arguments: idInt ?? linkId);
        return;
      }
    }
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      _saveToCache();
    }
  }

  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _saveToCache();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _saveToCache();
  }

  void clearAll() {
    notifications.clear();
    _saveToCache();
  }

  void _saveToCache() {
    try {
      final raw = notifications.map((n) => jsonEncode(n.toJson())).toList();
      _storageService?.saveNotificationsRaw(raw);
    } catch (e) {
      debugPrint('[NotificationController] saveToCache error: $e');
    }
  }
}
