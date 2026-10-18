import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

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
