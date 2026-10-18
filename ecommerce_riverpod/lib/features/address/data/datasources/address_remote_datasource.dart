import '../../../../app/data/providers/address_provider.dart';

abstract class AddressRemoteDataSource {
  Future<dynamic> getAddresses();
  Future<dynamic> addAddress(Map<String, dynamic> data);
  Future<dynamic> updateAddress(int id, Map<String, dynamic> data);
  Future<dynamic> deleteAddress(int id);
  Future<dynamic> setDefaultAddress(int id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final AddressProvider _provider;

  AddressRemoteDataSourceImpl(this._provider);

  @override
  Future<dynamic> getAddresses() async {
    final response = await _provider.getAddresses();
    return response.data;
  }

  @override
  Future<dynamic> addAddress(Map<String, dynamic> data) async {
    final response = await _provider.addAddress(data);
    return response.data;
  }

  @override
  Future<dynamic> updateAddress(int id, Map<String, dynamic> data) async {
    final response = await _provider.updateAddress(id, data);
    return response.data;
  }

  @override
  Future<dynamic> deleteAddress(int id) async {
    final response = await _provider.deleteAddress(id);
    return response.data;
  }

  @override
  Future<dynamic> setDefaultAddress(int id) async {
    final response = await _provider.setDefaultAddress(id);
    return response.data;
  }
}
