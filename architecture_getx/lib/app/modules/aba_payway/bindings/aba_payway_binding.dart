import 'package:get/get.dart';

import '../controllers/aba_payway_controller.dart';

class AbaPaywayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbaPayWayController>(() => AbaPayWayController());
  }
}
