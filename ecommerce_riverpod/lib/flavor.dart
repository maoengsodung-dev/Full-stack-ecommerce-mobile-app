import 'app/core/config/env_config.dart';
import 'app/core/config/flavor_config.dart';


class F {
  static Flavor get appFlavor => FlavorConfig.flavor;

  static set appFlavor(Flavor flavor) {
    FlavorConfig.flavor = flavor;
  }

  static String get name => FlavorConfig.name;
  static String get title => FlavorConfig.title;
  static String get baseUrl => FlavorConfig.baseUrl;
  static String get apiUrl => baseUrl;
  static String get apiKey => baseUrl;
}
