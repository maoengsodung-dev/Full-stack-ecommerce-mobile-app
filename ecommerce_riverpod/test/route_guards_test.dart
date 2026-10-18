import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:architecture_getx/app/core/router/route_guards.dart';
import 'package:architecture_getx/app/core/router/route_names.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/user.model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
  });

  group('RouteGuards and Admin Middleware Tests', () {
    test('Unauthenticated user is guarded correctly', () {
      expect(RouteGuards.isAuthenticated(storage), isFalse);
      expect(RouteGuards.isAdmin(storage), isFalse);

      // Accessing admin route as guest redirects to login
      expect(RouteGuards.guardRoute(RouteNames.admin, storage), RouteNames.auth);
      expect(RouteGuards.guardRoute(RouteNames.adminCreateProduct, storage), RouteNames.auth);
      expect(RouteGuards.guardRoute('/admin/any-subpath', storage), RouteNames.auth);

      // Accessing protected customer route as guest redirects to login
      expect(RouteGuards.guardRoute(RouteNames.checkout, storage), RouteNames.auth);
      expect(RouteGuards.guardRoute(RouteNames.orders, storage), RouteNames.auth);
      expect(RouteGuards.guardRoute(RouteNames.profile, storage), RouteNames.auth);

      // Public and guest routes allowed for guest
      expect(RouteGuards.guardRoute(RouteNames.splash, storage), isNull);
      expect(RouteGuards.guardRoute(RouteNames.auth, storage), isNull);
      expect(RouteGuards.guardRoute(RouteNames.shell, storage), isNull);
    });

    test('Regular customer cannot access admin routes', () async {
      await storage.saveToken('test-customer-token');
      await storage.saveIsAdmin(false);
      await storage.saveActiveRole('customer');
      await storage.saveUser(UserModel(
        success: true,
        data: Data(user: User(id: 1, name: 'John Customer', email: 'john@example.com', roles: ['customer'])),
      ));

      expect(RouteGuards.isAuthenticated(storage), isTrue);
      expect(RouteGuards.isAdmin(storage), isFalse);

      // Admin routes redirect customer to shell
      expect(RouteGuards.guardRoute(RouteNames.admin, storage), RouteNames.shell);
      expect(RouteGuards.guardRoute(RouteNames.adminCreateProduct, storage), RouteNames.shell);
      expect(RouteGuards.guardRoute('/admin/custom', storage), RouteNames.shell);

      // Guest routes redirect customer to shell
      expect(RouteGuards.guardRoute(RouteNames.auth, storage), RouteNames.shell);
      expect(RouteGuards.guardRoute(RouteNames.login, storage), RouteNames.shell);

      // Customer routes allowed
      expect(RouteGuards.guardRoute(RouteNames.orders, storage), isNull);
      expect(RouteGuards.guardRoute(RouteNames.checkout, storage), isNull);
      expect(RouteGuards.guardRoute(RouteNames.shell, storage), isNull);
    });

    test('Admin user with saved admin token can access admin routes', () async {
      await storage.saveToken('test-user-token');
      await storage.saveAdminToken('test-admin-secret-token');
      await storage.saveIsAdmin(true);
      await storage.saveActiveRole('admin');
      await storage.saveUser(UserModel(
        success: true,
        data: Data(user: User(id: 99, name: 'Super Admin', email: 'admin@example.com', roles: ['admin'])),
      ));

      expect(RouteGuards.isAuthenticated(storage), isTrue);
      expect(RouteGuards.isAdmin(storage), isTrue);
      expect(storage.getAdminToken(), 'test-admin-secret-token');

      // Admin routes are allowed
      expect(RouteGuards.guardRoute(RouteNames.admin, storage), isNull);
      expect(RouteGuards.guardRoute(RouteNames.adminCreateProduct, storage), isNull);
      expect(RouteGuards.guardRoute('/admin/settings', storage), isNull);

      // Guest routes redirect admin to adminDashboard
      expect(RouteGuards.guardRoute(RouteNames.auth, storage), RouteNames.adminDashboard);
      expect(RouteGuards.guardRoute(RouteNames.login, storage), RouteNames.adminDashboard);
      expect(RouteGuards.guardRoute(RouteNames.register, storage), RouteNames.adminDashboard);
    });
  });
}
