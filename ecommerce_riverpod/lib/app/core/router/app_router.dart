import 'package:flutter/material.dart';

import '../../../features/address/presentation/pages/address_form_page.dart';
import '../../../features/address/presentation/pages/address_list_page.dart';
import '../../../features/admin/data/models/category_model.dart';
import '../../../features/admin/data/models/order_model.dart';
import '../../../features/admin/data/models/product_model.dart';
import '../../../features/admin/presentation/pages/admin_page.dart';
import '../../../features/admin/presentation/pages/category/create_category_page.dart';
import '../../../features/admin/presentation/pages/category/update_category_page.dart';
import '../../../features/admin/presentation/pages/order/orders_page.dart' as admin_orders;
import '../../../features/admin/presentation/pages/order/update_order_status_page.dart';
import '../../../features/admin/presentation/pages/product/create_product_page.dart';
import '../../../features/admin/presentation/pages/product/update_product_page.dart';
import '../../../features/admin/presentation/pages/variant/add_variant_page.dart';
import '../../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/auth/presentation/pages/reset_password_page.dart';
import '../../../features/auth/presentation/pages/verify_email_page.dart';
import '../../../features/cart/presentation/pages/cart_page.dart';
import '../../../features/checkout/pages/checkout_page.dart';
import '../../../features/home/pages/home_page.dart';
import '../../../features/home/widgets/search_product.dart';
import '../../../features/language/pages/language_page.dart';
import '../../../features/main_page/pages/main_page.dart';
import '../../../features/notification/pages/notification_page.dart';
import '../../../features/orders/pages/order_detail_page.dart';
import '../../../features/orders/pages/order_success_page.dart';
import '../../../features/payment/pages/payment_page.dart';
import '../../../features/product_detail/pages/product_detail_page.dart';
import '../../../features/profile/pages/profile_page.dart';
import '../../../features/splash/pages/splash_page.dart';
import '../../../features/wishlist/pages/wishlist_page.dart';
import '../../data/models/order.model.dart';
import '../services/storage_service.dart';
import 'route_guards.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static StorageService? _storageService;

  static void init(StorageService storage) {
    _storageService = storage;
  }

  static Future<T?>? pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?>? pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static Future<T?>? pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName, [
    RoutePredicate? predicate,
    Object? arguments,
  ]) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (_storageService != null) {
      final target =
          RouteGuards.guardRoute(settings.name ?? '', _storageService!);
      if (target != null && target != settings.name) {
        return _buildRoute(
          RouteSettings(
            name: target,
            arguments: settings.arguments,
          ),
        );
      }
    }
    return _buildRoute(settings);
  }

  static Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashPage(),
        );

      case RouteNames.auth:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case RouteNames.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );

      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordPage(),
        );

      case RouteNames.resetPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResetPasswordPage(),
        );

      case RouteNames.verifyEmail:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VerifyEmailPage(),
        );

      case RouteNames.shell:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainPage(),
        );

      case RouteNames.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );

      case RouteNames.searchProduct:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchProduct(),
        );

      case RouteNames.productDetail:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailPage(
            productOrId: settings.arguments,
          ),
        );

      case RouteNames.cart:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartPage(),
        );

      case RouteNames.checkout:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CheckoutPage(),
        );

      case RouteNames.orderSuccess:
        OrderRes? order;
        String paymentMethod = 'ABA Payway';
        if (settings.arguments is OrderRes) {
          order = settings.arguments as OrderRes;
        } else if (settings.arguments is Map<String, dynamic>) {
          final map = settings.arguments as Map<String, dynamic>;
          if (map['order'] is OrderRes) order = map['order'] as OrderRes;
          if (map['paymentMethod'] is String) {
            paymentMethod = map['paymentMethod'] as String;
          }
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderSuccessPage(
            order: order,
            paymentMethod: paymentMethod,
          ),
        );

      case RouteNames.orders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const admin_orders.OrdersPage(),
        );

      case RouteNames.orderDetail:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderDetailPage(
            initialOrder: settings.arguments is OrderRes
                ? settings.arguments as OrderRes
                : null,
          ),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );

      case RouteNames.addressList:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressListPage(),
        );

      case RouteNames.addressForm:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressFormPage(),
        );

      case RouteNames.notification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationPage(),
        );

      case RouteNames.wishlist:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WishlistPage(),
        );

      case RouteNames.payment:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PaymentPage(
            arguments: settings.arguments is Map<String, dynamic>
                ? settings.arguments as Map<String, dynamic>
                : null,
          ),
        );

      case RouteNames.language:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LanguagePage(),
        );

      // Admin Routes
      case RouteNames.admin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminPage(),
        );

      case RouteNames.adminCreateCategory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateCategoryPage(),
        );

      case RouteNames.adminUpdateCategory:
        final category = settings.arguments as AdminCategory;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdateCategoryPage(category: category),
        );

      case RouteNames.adminCreateProduct:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateProductPage(),
        );

      case RouteNames.adminUpdateProduct:
        final product = settings.arguments as AdminProduct;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdateProductPage(product: product),
        );

      case RouteNames.adminAddVariant:
        final product = settings.arguments as AdminProduct;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddVariantPage(product: product),
        );

      case RouteNames.adminOrders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>  const admin_orders.OrdersPage(),
        );

      case RouteNames.adminUpdateOrderStatus:
        final order = settings.arguments as AdminOrder;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UpdateOrderStatusPage(order: order),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
