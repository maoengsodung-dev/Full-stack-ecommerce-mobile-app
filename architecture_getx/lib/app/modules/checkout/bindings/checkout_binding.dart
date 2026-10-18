import 'package:architecture_getx/app/data/repository/address_repository.dart';
import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:get/get.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CheckoutController(
      Get.find<OrderRepository>(),
      Get.find<AddressRepository>(),
    ));
  }
}
