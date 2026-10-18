import 'env_config.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  static Flavor _flavor = Flavor.dev;

  static Flavor get flavor => _flavor;

  static set flavor(Flavor f) {
    _flavor = f;
  }

  static String get name => _flavor.name;

  static String get title {
    switch (_flavor) {
      case Flavor.dev:
        return 'Project Dev';
      case Flavor.staging:
        return 'Project Staging';
      case Flavor.prod:
        return 'Project Prod';
    }
  }

  static String get baseUrl {
    switch (_flavor) {
      case Flavor.dev:
        return EnvConfig.apiBaseUrlDev;
      case Flavor.staging:
        return EnvConfig.apiBaseUrlStaging;
      case Flavor.prod:
        return EnvConfig.apiBaseUrlProd;
    }
  }
}
