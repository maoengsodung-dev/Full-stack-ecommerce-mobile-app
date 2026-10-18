import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.model.dart';
import '../providers/address_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(addressDataProvider));
});

class AddressRepository {
  final AddressProvider _provider;

  AddressRepository(this._provider);

  Future<List<AddressModel>> getAddresses() async {
    final response = await _provider.getAddresses();
    final data = response.data;
    final List raw = data['data'] ?? data ?? [];
    return raw.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> addAddress(Map<String, dynamic> data) async {
    final response = await _provider.addAddress(data);
    final body = response.data;
    return AddressModel.fromJson(body['data'] ?? body);
  }

  Future<AddressModel> updateAddress(int id, Map<String, dynamic> data) async {
    final response = await _provider.updateAddress(id, data);
    final body = response.data;
    return AddressModel.fromJson(body['data'] ?? body);
  }

  Future<void> deleteAddress(int id) async {
    await _provider.deleteAddress(id);
  }

  Future<void> setDefaultAddress(int id) async {
    await _provider.setDefaultAddress(id);
  }
}
