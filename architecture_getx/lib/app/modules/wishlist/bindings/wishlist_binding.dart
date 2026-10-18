import 'package:get/get.dart';

import '../../../data/repository/wishlist_repository.dart';
import '../controllers/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(
      () => WishlistController(
        Get.isRegistered<WishlistRepository>()
            ? Get.find<WishlistRepository>()
            : null,
      ),
    );
  }
}
