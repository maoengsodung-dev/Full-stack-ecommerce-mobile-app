import '../../../../app/data/models/address.model.dart';
import '../../../../app/data/repository/address_repository.dart';

class UpdateAddressUseCase {
  final AddressRepository _repository;

  UpdateAddressUseCase(this._repository);

  Future<AddressModel> call(int id, Map<String, dynamic> data) {
    return _repository.updateAddress(id, data);
  }
}
