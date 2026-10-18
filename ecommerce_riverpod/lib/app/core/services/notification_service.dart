import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../../data/models/notification_model.dart';
import '../../data/repository/notification_repository.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import 'storage_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          highImportanceChannel.id,
          highImportanceChannel.name,
          channelDescription: highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

class NotificationService {
  final StorageService _storageService;
  final NotificationRepository? _repository;

  void Function(NotificationModel item)? onNotificationReceived;

  NotificationService(this._storageService, [this._repository]);

  Future<NotificationService> init() async {
    await _initLocalNotifications();
    await _requestPermissions();
    await _subscribeToTopics();
    _initFCMListeners();
    _registerToken();

    return this;
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            if (data is Map<String, dynamic>) {
              handlePayloadNavigation(data);
            }
          } catch (_) {
            AppRouter.navigatorKey.currentState?.pushNamed(RouteNames.notification);
          }
        } else {
          AppRouter.navigatorKey.currentState?.pushNamed(RouteNames.notification);
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);
  }

  Future<void> _requestPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('[NotificationService] requestPermission error: $e');
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all');
      await FirebaseMessaging.instance.subscribeToTopic('promotions');
      await FirebaseMessaging.instance.subscribeToTopic('products');
      debugPrint('[NotificationService] Subscribed to topics: all, promotions, products');
    } catch (e) {
      debugPrint('[NotificationService] Topic subscription error: $e');
    }
  }

  void _initFCMListeners() {
    // 1. Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Foreground message received: ${message.data}');
      _showLocalNotification(message);
      _handleIncomingMessage(message);
    });

    // 2. Message clicked when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Message opened from background: ${message.data}');
      _handleIncomingMessage(message);
      handlePayloadNavigation(message.data);
    });

    // 3. App opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('[NotificationService] App launched from notification: ${message.data}');
        _handleIncomingMessage(message);
        Future.delayed(const Duration(milliseconds: 500), () {
          handlePayloadNavigation(message.data);
        });
      }
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Store Update';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          highImportanceChannel.id,
          highImportanceChannel.name,
          channelDescription: highImportanceChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleIncomingMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Store Update';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ??
        (message.data['event'] == 'new_product'
            ? 'product'
            : (message.data['event'] == 'new_promotion' ? 'promo' : 'system'));

    final item = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: Map<String, dynamic>.from(message.data),
      time: DateTime.now(),
      isRead: false,
    );

    _persistNotification(item);
    onNotificationReceived?.call(item);
  }

  void _persistNotification(NotificationModel item) {
    try {
      final existing = _storageService.getNotificationsRaw();
      final updated = [jsonEncode(item.toJson()), ...existing];
      if (updated.length > 50) {
        updated.removeRange(50, updated.length);
      }
      _storageService.saveNotificationsRaw(updated);
    } catch (e) {
      debugPrint('[NotificationService] Failed to persist notification: $e');
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && _repository != null) {
        await _repository.registerDeviceToken(
          token: token,
          platform: Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'),
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (_repository != null) {
          await _repository.registerDeviceToken(
            token: newToken,
            platform: Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'),
          );
        }
      });
    } catch (e) {
      debugPrint('[NotificationService] Token registration error: $e');
    }
  }

  static void handlePayloadNavigation(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final event = data['event']?.toString();
    final slug = data['slug']?.toString();
    final productId = data['product_id']?.toString() ?? data['id']?.toString();

    if (type == 'product' || event == 'new_product') {
      if (slug != null && slug.isNotEmpty) {
        AppRouter.navigatorKey.currentState?.pushNamed(
          RouteNames.productDetail,
          arguments: slug,
        );
        return;
      } else if (productId != null && productId.isNotEmpty) {
        final idInt = int.tryParse(productId);
        AppRouter.navigatorKey.currentState?.pushNamed(
          RouteNames.productDetail,
          arguments: idInt ?? productId,
        );
        return;
      }
    }

    AppRouter.navigatorKey.currentState?.pushNamed(RouteNames.notification);
  }
}
