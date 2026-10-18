
import '../config/env_config.dart';
import '../config/flavor_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => FlavorConfig.baseUrl;

  // Products & Categories
  static const String products = '/products';
  static const String categories = '/categories';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Device Tokens
  static const String deviceTokens = '/device-tokens';

  // Addresses
  static const String addresses = '/addresses';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Orders
  static const String orders = '/orders';

  // Admin
  static const String adminCategories = '/admin/categories';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminBanners = '/admin/banners';

  // Banners & Notifications & Wishlist
  static const String banners = '/banners';
  static const String notifications = '/notifications';
  static const String wishlist = '/wishlist';

  // Payments
  static const String payWayCreate = '/payments/payway/create';
  static const String payWayStatus = '/payments/payway/status';

  // ABA Configuration
  static String get abaMerchantName => EnvConfig.abaMerchantName;
  static String get abaMerchantApiKey => EnvConfig.abaMerchantApiKey;
  static String get abaBaseUrl => EnvConfig.abaBaseUrl;
  static String get abaMerchantId => EnvConfig.abaMerchantId;
  static String get abaRefererDomain => EnvConfig.abaRefererDomain;
  static String get abaReturnUrl => EnvConfig.abaReturnUrl;

  static const double usdToKhrRate = 4100;
}

// Global convenience getters matching existing codebase
String get baseUrl => ApiConstants.baseUrl;
const kProducts = ApiConstants.products;
const kCategories = ApiConstants.categories;
const kLogin = ApiConstants.login;
const kRegister = ApiConstants.register;
const kLogout = ApiConstants.logout;
const kProfile = ApiConstants.profile;
const kRefreshToken = ApiConstants.refreshToken;
const kForgotPassword = ApiConstants.forgotPassword;
const kResetPassword = ApiConstants.resetPassword;
const kDeviceTokens = ApiConstants.deviceTokens;
const kAddresses = ApiConstants.addresses;
const kCart = ApiConstants.cart;
const kCartItems = ApiConstants.cartItems;
const kOrders = ApiConstants.orders;
const kAdminCategories = ApiConstants.adminCategories;
const kAdminProducts = ApiConstants.adminProducts;
const kAdminOrders = ApiConstants.adminOrders;
const kAdminBanners = ApiConstants.adminBanners;
const kBanners = ApiConstants.banners;
const kNotifications = ApiConstants.notifications;
const kWishlist = ApiConstants.wishlist;
const kPayWayCreate = ApiConstants.payWayCreate;
const kPayWayStatus = ApiConstants.payWayStatus;
const products = kProducts;
const categories = kCategories;
String get kMerchantName => ApiConstants.abaMerchantName;
String get kMerchantApiKey => ApiConstants.abaMerchantApiKey;
String get kBaseUrlBank => ApiConstants.abaBaseUrl;
String get kBaseUrl => kBaseUrlBank;
String get kMerchantId => ApiConstants.abaMerchantId;
String get kMerchantID => kMerchantId;
const double kUsdToKhrRate = ApiConstants.usdToKhrRate;
const double kUsdToKhRate = kUsdToKhrRate;
String get kRefererDomain => ApiConstants.abaRefererDomain;
String get kReturnUrl => ApiConstants.abaReturnUrl;
