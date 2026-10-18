import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';


final addressDataProvider = Provider<AddressProvider>((ref) {
  return AddressProvider(ref.watch(apiClientProvider));
});

class AddressProvider {
  final ApiClient _apiClient;

  AddressProvider(this._apiClient);

  Future<Response> getAddresses() async {
    return await _apiClient.get(kAddresses);
  }

  Future<Response> addAddress(Map<String, dynamic> data) async {
    return await _apiClient.post(kAddresses, data: data);
  }

  Future<Response> updateAddress(int id, Map<String, dynamic> data) async {
    return await _apiClient.put('$kAddresses/$id', data: data);
  }

  Future<Response> deleteAddress(int id) async {
    return await _apiClient.delete('$kAddresses/$id');
  }

  Future<Response> setDefaultAddress(int id) async {
    return await _apiClient.patch('$kAddresses/$id/default');
  }
}
