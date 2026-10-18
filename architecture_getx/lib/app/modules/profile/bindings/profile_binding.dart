import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/repository/auth_repository.dart';
import 'package:architecture_getx/app/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(() => ProfileController(Get.find<AuthRepository>(), Get.find<StorageService>()));
    }
  }
}
