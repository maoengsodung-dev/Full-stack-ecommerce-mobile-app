import 'package:architecture_getx/app/data/repository/cart_repository.dart';
import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/data/repository/wishlist_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/modules/orders/controllers/orders_controller.dart';
import 'package:architecture_getx/app/modules/wishlist/controllers/wishlist_controller.dart';

import 'package:get/get.dart';

import '../controllers/main_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController(), permanent: true);
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(Get.find<CartRepository>()), permanent: true);
    }
    Get.put(OrdersController(Get.find<OrderRepository>()), permanent: true);
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(
        WishlistController(
          Get.isRegistered<WishlistRepository>()
              ? Get.find<WishlistRepository>()
              : null,
        ),
        permanent: true,
      );
    }
  }
}
