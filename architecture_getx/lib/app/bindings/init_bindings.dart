import 'package:architecture_getx/app/core/network/api_client.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/providers/address_provider.dart';
import 'package:architecture_getx/app/data/providers/auth_provider.dart';
import 'package:architecture_getx/app/data/providers/banner_provider.dart';
import 'package:architecture_getx/app/data/providers/cart_provider.dart';
import 'package:architecture_getx/app/data/providers/category_provider.dart';
import 'package:architecture_getx/app/data/providers/order_provider.dart';
import 'package:architecture_getx/app/data/providers/product_provider.dart';
import 'package:architecture_getx/app/data/providers/wishlist_provider.dart';
import 'package:architecture_getx/app/data/repository/address_repository.dart';
import 'package:architecture_getx/app/data/repository/auth_repository.dart';
import 'package:architecture_getx/app/data/repository/banner_repository.dart';
import 'package:architecture_getx/app/data/repository/cart_repository.dart';
import 'package:architecture_getx/app/data/repository/category_repository.dart';
import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/data/repository/product_repository.dart';
import 'package:architecture_getx/app/data/repository/wishlist_repository.dart';
import 'package:architecture_getx/app/data/providers/notification_provider.dart';
import 'package:architecture_getx/app/data/repository/notification_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/modules/notification/controllers/notification_controller.dart';
import 'package:architecture_getx/app/modules/profile/controllers/profile_controller.dart';
import 'package:architecture_getx/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:get/get.dart';

class InitBindings extends Bindings {
  @override
  void dependencies() {
    // Core
    // StorageService is pre-registered in main.dart before runApp()
    // ApiClient receives it to inject auth token synchronously
    Get.put<ApiClient>(ApiClient(Get.find<StorageService>()), permanent: true);

    // Providers
    Get.put<ProductProvider>(
      ProductProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<AuthProvider>(AuthProvider(Get.find<ApiClient>()), permanent: true);
    Get.put<AddressProvider>(
      AddressProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<CartProvider>(CartProvider(Get.find<ApiClient>()), permanent: true);
    Get.put<WishlistProvider>(
      WishlistProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<OrderProvider>(
      OrderProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<CategoryProvider>(
      CategoryProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<BannerProvider>(
      BannerProvider(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<NotificationProvider>(
      NotificationProvider(Get.find<ApiClient>()),
      permanent: true,
    );

    // Repositories
    Get.put<ProductRepository>(
      ProductRepository(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put<CategoryRepository>(
      CategoryRepository(Get.find<CategoryProvider>()),
      permanent: true,
    );
    Get.put<BannerRepository>(
      BannerRepository(Get.find<BannerProvider>()),
      permanent: true,
    );
    Get.put<NotificationRepository>(
      NotificationRepository(Get.find<NotificationProvider>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepository(Get.find<AuthProvider>()),
      permanent: true,
    );
    Get.put<AddressRepository>(
      AddressRepository(Get.find<AddressProvider>()),
      permanent: true,
    );
    Get.put<CartRepository>(
      CartRepository(Get.find<CartProvider>()),
      permanent: true,
    );
    Get.put<WishlistRepository>(
      WishlistRepository(Get.find<WishlistProvider>()),
      permanent: true,
    );
    Get.put<OrderRepository>(
      OrderRepository(Get.find<OrderProvider>()),
      permanent: true,
    );

    // Controllers
    Get.put<CartController>(
      CartController(Get.find<CartRepository>()),
      permanent: true,
    );
    Get.put<WishlistController>(
      WishlistController(Get.find<WishlistRepository>()),
      permanent: true,
    );
    Get.put<NotificationController>(
      NotificationController(),
      permanent: true,
    );
    Get.put<ProfileController>(
      ProfileController(Get.find<AuthRepository>(), Get.find<StorageService>()),
      permanent: true,
    );
  }
}
