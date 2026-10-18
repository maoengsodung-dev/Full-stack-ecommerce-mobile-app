import '../../../../app/data/models/address.model.dart';
import '../../../../app/data/repository/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository _repository;

  GetAddressesUseCase(this._repository);

  Future<List<AddressModel>> call() {
    return _repository.getAddresses();
  }
}
