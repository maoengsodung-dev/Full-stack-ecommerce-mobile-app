import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/notification_model.dart';
import '../../../app/data/repository/notification_repository.dart';
import '../../../app/core/providers/storage_providers.dart';

class NotificationState {
  final AsyncValue<List<NotificationModel>> notifications;

  const NotificationState({
    this.notifications = const AsyncValue.loading(),
  });

  List<NotificationModel> get items => notifications.valueOrNull ?? [];
  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    AsyncValue<List<NotificationModel>>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final storage = ref.watch(storageServiceProvider);
    final cachedRaw = storage.getNotificationsRaw();
    List<NotificationModel> cached = [];
    if (cachedRaw.isNotEmpty) {
      try {
        cached = cachedRaw.map((str) {
          final json = jsonDecode(str) as Map<String, dynamic>;
          return NotificationModel.fromJson(json);
        }).toList();
      } catch (_) {}
    }

    Future.microtask(() => fetchNotifications());

    return NotificationState(
      notifications: AsyncValue.data(cached),
    );
  }

  Future<void> fetchNotifications() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final serverItems = await repo.getNotifications();
      if (serverItems.isNotEmpty) {
        final currentItems = state.items;
        final existingMap = {for (final n in currentItems) n.id: n};
        for (final s in serverItems) {
          if (existingMap.containsKey(s.id)) {
            s.isRead = existingMap[s.id]!.isRead;
          }
        }

        final serverIds = serverItems.map((e) => e.id).toSet();
        final localOnly =
            currentItems.where((n) => !serverIds.contains(n.id)).toList();

        final merged = [...localOnly, ...serverItems];
        merged.sort((a, b) => b.time.compareTo(a.time));

        _saveToCache(merged);
        state = state.copyWith(notifications: AsyncValue.data(merged));
      }
    } catch (e, st) {
      if (state.items.isEmpty) {
        state = state.copyWith(notifications: AsyncValue.error(e, st));
      }
    }
  }

  void markAsRead(String id) {
    final updated = state.items.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    _saveToCache(updated);
    state = state.copyWith(notifications: AsyncValue.data(updated));
  }

  void markAllAsRead() {
    final updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
    _saveToCache(updated);
    state = state.copyWith(notifications: AsyncValue.data(updated));
  }

  void deleteNotification(String id) {
    final updated = state.items.where((n) => n.id != id).toList();
    _saveToCache(updated);
    state = state.copyWith(notifications: AsyncValue.data(updated));
  }

  void clearAll() {
    _saveToCache([]);
    state = state.copyWith(notifications: const AsyncValue.data([]));
  }

  void _saveToCache(List<NotificationModel> list) {
    try {
      final storage = ref.read(storageServiceProvider);
      final raw = list.map((n) => jsonEncode(n.toJson())).toList();
      storage.saveNotificationsRaw(raw);
    } catch (_) {}
  }
}

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
