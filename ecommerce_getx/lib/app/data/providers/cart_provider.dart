import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class CartProvider {
  final ApiClient _apiClient;

  CartProvider(this._apiClient);

  Future<Response> getCart() async {
    return await _apiClient.get(kCart);
  }

  Future<Response> addItem(int productId, int quantity, {int? variantId}) async {
    return await _apiClient.post(
      kCartItems,
      data: {
        'product_id': productId,
        'quantity': quantity,
        'product_variant_id': ?variantId,
      },
    );
  }

  Future<Response> updateItem(int itemId, int quantity) async {
    return await _apiClient.patch(
      '$kCartItems/$itemId',
      data: {'quantity': quantity},
    );
  }

  Future<Response> removeItem(int itemId) async {
    return await _apiClient.delete('$kCartItems/$itemId');
  }

  Future<Response> clearCart() async {
    return await _apiClient.delete(kCart);
  }
}
