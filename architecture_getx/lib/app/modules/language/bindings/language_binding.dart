import 'package:get/get.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import '../controllers/language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(Get.find<StorageService>()),
    );
  }
}
