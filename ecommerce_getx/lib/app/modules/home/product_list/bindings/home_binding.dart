import 'package:architecture_getx/app/data/repository/banner_repository.dart';
import 'package:architecture_getx/app/data/repository/category_repository.dart';
import 'package:architecture_getx/app/data/repository/product_repository.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<ProductRepository>(),
        categoryRepository: Get.find<CategoryRepository>(),
        bannerRepository: Get.find<BannerRepository>(),
      ),
    );
  }
}
