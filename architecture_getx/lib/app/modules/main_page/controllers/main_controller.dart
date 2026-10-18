import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/modules/cart/views/cart_view.dart';
import 'package:architecture_getx/app/modules/orders/views/orders_view.dart';
import 'package:architecture_getx/app/modules/profile/views/profile_view.dart';
import 'package:architecture_getx/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:architecture_getx/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';

import '../../home/product_list/views/home_view.dart';

class MainController extends GetxController {
  var selectIndex = 0.obs;

  final screens = [HomeView(), CartView(), OrdersView(), WishlistView(), ProfileView()];

  void changeScreen(int index) {
    selectIndex.value = index;
    if (index == 1 && Get.isRegistered<CartController>()) {
      Get.find<CartController>().fetchCart(showLoading: false);
    }
    if (index == 3 && Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().fetchWishlist(showLoading: false);
    }
  }

}
