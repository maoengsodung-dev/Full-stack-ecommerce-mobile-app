import 'package:architecture_getx/app/core/config/env_config.dart';
import 'package:architecture_getx/flavor.dart';

// Dynamically resolved baseUrl according to the active flavor (prod, staging, dev)
String get baseUrl => F.baseUrl;



// Products
const kProducts = '/products';
const kCategories = '/categories';

// Auth
const kLogin = '/auth/login';
const kRegister = '/auth/register';
const kLogout = '/auth/logout';
const kProfile = '/auth/me';
const kRefreshToken = '/auth/refresh';
const kForgotPassword = '/auth/forgot-password';
const kResetPassword = '/auth/reset-password';

// Device Tokens
const kDeviceTokens = '/device-tokens';

// Addresses
const kAddresses = '/addresses';

// Cart
const kCart = '/cart';
const kCartItems = '/cart/items';

// Orders
const kOrders = '/orders';

// Admin Endpoints (Laravel 11 REST API)
const kAdminCategories = '/admin/categories';
const kAdminProducts = '/admin/products';
const kAdminOrders = '/admin/orders';
const kAdminBanners = '/admin/banners';
const kBanners = '/banners';

// Notifications
const kNotifications = '/notifications';

// Wishlist
const kWishlist = '/wishlist';

// Payments
const kPayWayCreate = '/payments/payway/create';
const kPayWayStatus = '/payments/payway/status';

// Backward compat aliases
const products = kProducts;
const categories = kCategories;

// ABA PayWay credentials & configuration — loaded from .env at build time
String get kMerchantName => EnvConfig.abaMerchantName;
String get kMerchantApiKey => EnvConfig.abaMerchantApiKey;
String get kBaseUrlBank => EnvConfig.abaBaseUrl;
String get kBaseUrl => kBaseUrlBank;
String get kMerchantId => EnvConfig.abaMerchantId;
String get kMerchantID => kMerchantId;

// Prices shown in USD but merchant accepts KHR -> convert at checkout.
const double kUsdToKhrRate = 4100;
const double kUsdToKhRate = kUsdToKhrRate;

// Referer domain and return URL for ABA PayWay
String get kRefererDomain => EnvConfig.abaRefererDomain;
String get kReturnUrl => EnvConfig.abaReturnUrl;

