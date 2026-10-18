import 'package:architecture_getx/app/data/repository/product_repository.dart';
import 'package:architecture_getx/app/modules/product_detail/controllers/product_detail_controller.dart';
import 'package:get/get.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductDetailController(Get.find<ProductRepository>()));
  }
}
