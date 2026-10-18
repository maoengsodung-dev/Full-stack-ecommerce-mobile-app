import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'app/core/config/flavor_config.dart';
import 'app/core/providers/storage_providers.dart';
import 'app/core/router/app_router.dart';
import 'app/core/services/notification_service.dart';


import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';
import 'firebase_options_staging.dart';
import 'flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
    orElse: () => Flavor.dev,
  );

  // Set Firebase options with flavor
  await Firebase.initializeApp(
    options: switch (F.appFlavor) {
      Flavor.dev => DefaultFirebaseOptionsDev.currentPlatform,
      Flavor.staging => DefaultFirebaseOptionsStaging.currentPlatform,
      Flavor.prod => DefaultFirebaseOptionsProd.currentPlatform,
    },
  );

  // Initialize storage & router middleware
  final storageService = StorageService();
  await storageService.init();
  AppRouter.init(storageService);

  // Initialize notification service & background handler
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  final notificationService = NotificationService(storageService);
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const App(),
    ),
  );
}