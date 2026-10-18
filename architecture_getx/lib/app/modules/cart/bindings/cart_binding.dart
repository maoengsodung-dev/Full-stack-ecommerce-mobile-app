import 'package:architecture_getx/app/data/repository/cart_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController(Get.find<CartRepository>()));
  }
}
