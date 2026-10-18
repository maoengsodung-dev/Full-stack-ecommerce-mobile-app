import 'package:architecture_getx/app/data/repository/address_repository.dart';
import 'package:architecture_getx/app/modules/address/controllers/address_controller.dart';
import 'package:get/get.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddressController>(AddressController(Get.find<AddressRepository>()));
  }
}
