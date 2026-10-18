import 'env_config.dart';

import 'flavor_config.dart';

class AppConfig {
  static const String appName = 'E-Commerce Atelier';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  static Flavor get flavor => FlavorConfig.flavor;
  static String get baseUrl => FlavorConfig.baseUrl;

  static bool get isDev => flavor == Flavor.dev;
  static bool get isStaging => flavor == Flavor.staging;
  static bool get isProd => flavor == Flavor.prod;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
