import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/modules/orders/controllers/orders_controller.dart';
import 'package:get/get.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrdersController(Get.find<OrderRepository>()));
  }
}
