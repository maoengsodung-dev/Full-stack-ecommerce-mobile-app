/// Reads values injected at build time via `--dart-define-from-file=.env`.
///
/// Usage:
///   flutter run --dart-define-from-file=.env
///   flutter build apk --release --dart-define-from-file=.env
class EnvConfig {
  // App
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  //API Base URLs (per flavor)
  static const String apiBaseUrlDev = String.fromEnvironment(
    'API_BASE_URL_DEV',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String apiBaseUrlStaging = String.fromEnvironment(
    'API_BASE_URL_STAGING',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String apiBaseUrlProd = String.fromEnvironment(
    'API_BASE_URL_PROD',
    defaultValue: 'http://206.189.34.193/api/v1',
  );

  // ABA PayWay
  static const String abaMerchantName = String.fromEnvironment(
    'ABA_MERCHANT_NAME',
    defaultValue: 'Sodung Maoeng',
  );

  static const String abaMerchantApiKey = String.fromEnvironment(
    'ABA_MERCHANT_API_KEY',
    defaultValue: '',
  );

  static const String abaMerchantId = String.fromEnvironment(
    'ABA_MERCHANT_ID',
    defaultValue: '',
  );

  static const String abaBaseUrl = String.fromEnvironment(
    'ABA_BASE_URL',
    defaultValue: 'https://checkout-sandbox.payway.com.kh',
  );

  // Return URLs
  static const String abaRefererDomain = String.fromEnvironment(
    'ABA_REFERER_DOMAIN',
    defaultValue: 'https://avance-system.com',
  );

  static const String abaReturnUrl = String.fromEnvironment(
    'ABA_RETURN_URL',
    defaultValue: 'https://avance-system.com/aba-payway-return',
  );
}
