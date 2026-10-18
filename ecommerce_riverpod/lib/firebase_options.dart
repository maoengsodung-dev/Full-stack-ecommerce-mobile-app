// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'app/core/config/flavor_config.dart';
import 'flavor.dart';
import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';
import 'firebase_options_staging.dart';

/// Default [FirebaseOptions] provider for the current flavor and platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (F.appFlavor) {
      case Flavor.dev:
        return DefaultFirebaseOptionsDev.currentPlatform;
      case Flavor.staging:
        return DefaultFirebaseOptionsStaging.currentPlatform;
      case Flavor.prod:
        return DefaultFirebaseOptionsProd.currentPlatform;
    }
  }
}
