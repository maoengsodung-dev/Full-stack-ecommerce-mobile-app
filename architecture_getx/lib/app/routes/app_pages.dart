import 'package:get/get.dart';

import '../core/middleware/auth_middleware.dart';
import '../data/models/product.model.dart';
import '../modules/aba_payway/bindings/aba_payway_binding.dart';
import '../modules/aba_payway/views/aba_payway_view.dart';
import '../modules/address/bindings/address_binding.dart';
import '../modules/address/views/address_form_view.dart';
import '../modules/address/views/address_list_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/admin/views/category/create_category_view.dart';
import '../modules/admin/views/category/update_category_view.dart';
import '../modules/admin/views/order/orders_view.dart';
import '../modules/admin/views/order/update_order_status_view.dart';
import '../modules/admin/views/product/create_product_view.dart';
import '../modules/admin/views/product/update_product_view.dart';
import '../modules/admin/views/variant/add_variant_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/home/product_list/bindings/home_binding.dart';
import '../modules/home/product_list/views/home_view.dart';
import '../modules/home/product_list/widgets/search_product.dart';
import '../modules/main_page/bindings/shell_binding.dart';
import '../modules/main_page/views/main_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/order_success/views/order_success_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/order_detail_view.dart';
import '../modules/orders/views/orders_view.dart' as customer_orders;
import '../modules/product_detail/bindings/product_detail_binding.dart';
import '../modules/product_detail/views/product_detail_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/wishlist/bindings/wishlist_binding.dart';
import '../modules/wishlist/views/wishlist_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Start at Splash Screen
  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    // ── Guest routes (redirect to shell if already logged in) ──────────────────
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const AuthView(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()],
    ),

    // ── Protected routes (redirect to login if not authenticated) ──────────────
    GetPage(
      name: _Paths.SHELL,
      page: () => const MainView(),
      binding: ShellBinding(),
      bindings: [HomeBinding(), OrdersBinding(), ProfileBinding()],
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.SEARCH_PRODUCT,
      page: () => const SearchProduct(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => ProductDetailView(pro: Get.arguments is ProductRes ? Get.arguments as ProductRes : null),
      binding: ProductDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.ORDER_SUCCESS,
      page: () => const OrderSuccessView(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.ORDERS,
      page: () => const customer_orders.OrdersView(),
      binding: OrdersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrdersBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: _Paths.ADDRESS_LIST,
      page: () => const AddressListView(),
      binding: AddressBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADDRESS_FORM,
      page: () => const AddressFormView(),
      binding: AddressBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Notification
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ABA_PAYWAY,
      page: () => const AbaPayWayView(),
      binding: AbaPaywayBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),

    // ── Admin Module ────────────────────────────────────────────────────────
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_CREATE_CATEGORY,
      page: () => const CreateCategoryView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_UPDATE_CATEGORY,
      page: () => const UpdateCategoryView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_CREATE_PRODUCT,
      page: () => const CreateProductView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_UPDATE_PRODUCT,
      page: () => const UpdateProductView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_ADD_VARIANT,
      page: () => const AddVariantView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_ORDERS,
      page: () => const OrdersView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: _Paths.ADMIN_UPDATE_ORDER_STATUS,
      page: () => const UpdateOrderStatusView(),
      binding: AdminBinding(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}
