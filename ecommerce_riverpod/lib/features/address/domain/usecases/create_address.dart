import '../../../../app/data/models/address.model.dart';
import '../../../../app/data/repository/address_repository.dart';

class CreateAddressUseCase {
  final AddressRepository _repository;

  CreateAddressUseCase(this._repository);

  Future<AddressModel> call(Map<String, dynamic> data) {
    return _repository.addAddress(data);
  }
}
