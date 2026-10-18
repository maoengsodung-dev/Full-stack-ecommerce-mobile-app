import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';




final productDataProvider = Provider<ProductProvider>((ref) {
  return ProductProvider(ref.watch(apiClientProvider));
});

class ProductProvider {
  final ApiClient _apiClient;

  ProductProvider(this._apiClient);

  Future<Response> getProduct() async {
    return await _apiClient.get(kProducts);
  }
}