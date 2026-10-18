import '../../../../app/data/repository/address_repository.dart';

class SetDefaultAddressUseCase {
  final AddressRepository _repository;

  SetDefaultAddressUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.setDefaultAddress(id);
  }
}
