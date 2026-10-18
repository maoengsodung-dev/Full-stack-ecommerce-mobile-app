import 'package:architecture_getx/app/core/network/api_client.dart';
import 'package:architecture_getx/app/core/services/notification_service.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/providers/notification_provider.dart';
import 'package:architecture_getx/app/data/repository/notification_repository.dart';
import 'package:architecture_getx/firebase_options_dev.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'firebase_options_prod.dart';
import 'firebase_options_staging.dart';
import 'flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
    orElse: () => Flavor.dev,
  );

  // set firebase options with flavor
  await Firebase.initializeApp(
    options: switch (F.appFlavor) {
      Flavor.dev => DefaultFirebaseOptionsDev.currentPlatform,
      Flavor.staging => DefaultFirebaseOptionsStaging.currentPlatform,
      Flavor.prod => DefaultFirebaseOptionsProd.currentPlatform,
    },
  );

  // Initialize storage
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // Initialize network & notification repository
  final apiClient = ApiClient(storageService);
  final notificationProvider = NotificationProvider(apiClient);
  final notificationRepo = NotificationRepository(notificationProvider);
  Get.put(notificationRepo, permanent: true);

  // Initialize notification service & background handler
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  final notificationService =
      NotificationService(storageService, notificationRepo);
  await notificationService.init();
  Get.put(notificationService, permanent: true);

  runApp(const App());
}