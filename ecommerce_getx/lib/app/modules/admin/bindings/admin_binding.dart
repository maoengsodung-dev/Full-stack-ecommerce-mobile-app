import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../providers/admin_provider.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProvider>(() => AdminProvider());
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
