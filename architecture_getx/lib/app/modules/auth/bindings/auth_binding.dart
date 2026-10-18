import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/repository/auth_repository.dart';
import 'package:architecture_getx/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>(), Get.find<StorageService>()),
    );
  }
}
