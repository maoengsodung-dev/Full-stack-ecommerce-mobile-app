import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class OrderProvider {
  final ApiClient _apiClient;

  OrderProvider(this._apiClient);

  Future<Response> getOrders({int page = 1, int perPage = 15}) async {
    return await _apiClient.get(kOrders, queryParameters: {
      'page': page,
      'per_page': perPage,
    });
  }

  Future<Response> getOrderDetail(dynamic orderNumberOrId) async {
    return await _apiClient.get('$kOrders/$orderNumberOrId');
  }

  Future<Response> placeOrder({
    required int addressId,
    String? note,
    String? notes,
    String paymentMethod = 'payway',
    String? paymentOption,
  }) async {
    final finalNote = (note != null && note.isNotEmpty)
        ? note
        : (notes != null && notes.isNotEmpty ? notes : null);

    return await _apiClient.post(kOrders, data: {
      'address_id': addressId,
      'note': ?finalNote,
      'payment_method': paymentMethod,
      if (paymentOption != null && paymentOption.isNotEmpty)
        'payment_option': paymentOption,
    });
  }

  Future<Response> cancelOrder(int id, {String? reason}) async {
    return await _apiClient.post('$kOrders/$id/cancel', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }

  Future<Response> deleteOrder(int id) async {
    return await _apiClient.delete('$kOrders/$id');
  }

  Future<Response> deleteOrderItem(int orderId, int itemId) async {
    return await _apiClient.delete('$kOrders/$orderId/items/$itemId');
  }
}
