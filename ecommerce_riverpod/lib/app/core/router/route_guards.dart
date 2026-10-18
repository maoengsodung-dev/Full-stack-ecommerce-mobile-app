import '../services/storage_service.dart';
import 'route_names.dart';

class RouteGuards {
  RouteGuards._();

  static bool isAuthenticated(StorageService storage) {
    return storage.hasToken;
  }

  static bool isAdmin(StorageService storage) {
    if (!storage.hasToken) return false;
    final user = storage.getUser();
    final roles = user?.roles ?? user?.data?.user?.roles ?? [];
    final hasAdminRole = roles.any((r) => r.toLowerCase().contains('admin'));
    return storage.isAdmin ||
        hasAdminRole ||
        user?.isAdmin == true ||
        (storage.getAdminToken() != null &&
            storage.getAdminToken()!.trim().isNotEmpty) ||
        storage.getActiveRole().toLowerCase() == 'admin';
  }

  static String? guardRoute(String route, StorageService storage) {
    final guestRoutes = [
      RouteNames.auth,
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.resetPassword,
      RouteNames.verifyEmail,
    ];

    final adminRoutes = [
      RouteNames.admin,
      RouteNames.adminPage,
      RouteNames.adminDashboard,
      RouteNames.adminCreateCategory,
      RouteNames.adminUpdateCategory,
      RouteNames.adminCreateProduct,
      RouteNames.adminUpdateProduct,
      RouteNames.adminAddVariant,
      RouteNames.adminOrders,
      RouteNames.adminUpdateOrderStatus,
    ];

    final isAdminRoute =
        adminRoutes.contains(route) || route.startsWith('/admin');

    // 1. If user is already authenticated and visits a guest route (e.g. login, register):
    if (guestRoutes.contains(route) && isAuthenticated(storage)) {
      if (isAdmin(storage)) {
        return RouteNames.adminDashboard;
      }
      return RouteNames.shell;
    }

    // 2. Admin routes middleware:
    if (isAdminRoute) {
      if (!isAuthenticated(storage)) {
        return RouteNames.auth;
      }
      if (!isAdmin(storage)) {
        return RouteNames.shell;
      }
    }

    // 3. Protected customer routes that require login:
    final protectedCustomerRoutes = [
      RouteNames.checkout,
      RouteNames.orders,
      RouteNames.orderDetail,
      RouteNames.profile,
      RouteNames.editProfile,
      RouteNames.changePassword,
      RouteNames.addressList,
      RouteNames.addressForm,
      RouteNames.payment,
      RouteNames.paymentWebview,
      RouteNames.paymentSuccess,
      RouteNames.abaPayway,
      RouteNames.wishlist,
      RouteNames.notification,
    ];

    if (protectedCustomerRoutes.contains(route) && !isAuthenticated(storage)) {
      return RouteNames.auth;
    }

    return null;
  }
}
