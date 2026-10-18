import '../../../../app/data/repository/address_repository.dart';

class DeleteAddressUseCase {
  final AddressRepository _repository;

  DeleteAddressUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteAddress(id);
  }
}
