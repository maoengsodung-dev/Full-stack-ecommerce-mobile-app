import 'package:architecture_getx/app/core/config/env_config.dart';

enum Flavor { dev, staging, prod }

class F {
  static Flavor? _appFlavor;

  static Flavor get appFlavor => _appFlavor ?? Flavor.dev;

  static set appFlavor(Flavor flavor) {
    _appFlavor = flavor;
  }

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Project Dev';
      case Flavor.staging:
        return 'Project Staging';
      case Flavor.prod:
        return 'Project Prod';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return EnvConfig.apiBaseUrlDev;
      case Flavor.staging:
        return EnvConfig.apiBaseUrlStaging;
      case Flavor.prod:
        return EnvConfig.apiBaseUrlProd;
    }
  }

  static String get apiUrl => baseUrl;
  static String get apiKey => baseUrl;
}
