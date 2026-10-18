import '../models/order.model.dart';
import '../providers/order_provider.dart';

class OrderRepository {
  final OrderProvider _provider;

  OrderRepository(this._provider);

  Future<List<OrderRes>> getOrders({int page = 1}) async {
    final response = await _provider.getOrders(page: page);
    final data = response.data;
    final List raw;
    if (data is Map && data['data'] is List) {
      raw = data['data'] as List;
    } else if (data is List) {
      raw = data;
    } else {
      raw = [];
    }
    return raw
        .map((e) => OrderRes.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<OrderRes> getOrderDetail(dynamic orderNumberOrId) async {
    final response = await _provider.getOrderDetail(orderNumberOrId);
    final data = response.data;
    final Map<String, dynamic> raw;
    if (data is Map && data['data'] is Map) {
      raw = Map<String, dynamic>.from(data['data']);
    } else if (data is Map) {
      raw = Map<String, dynamic>.from(data);
    } else {
      raw = {};
    }
    return OrderRes.fromJson(raw);
  }

  Future<OrderRes> placeOrder({
    required int addressId,
    String? note,
    String? notes,
    String paymentMethod = 'payway',
    String? paymentOption,
  }) async {
    final response = await _provider.placeOrder(
      addressId: addressId,
      note: note,
      notes: notes,
      paymentMethod: paymentMethod,
      paymentOption: paymentOption,
    );
    final data = response.data;
    final orderJson = data is Map && data['data'] is Map && data['data']['order'] != null
        ? data['data']['order']
        : (data is Map && data['data'] != null ? data['data'] : data);
    return OrderRes.fromJson(orderJson);
  }

  Future<OrderRes?> cancelOrder(int id, {String? reason}) async {
    final response = await _provider.cancelOrder(id, reason: reason);
    final data = response.data;
    if (data != null) {
      return OrderRes.fromJson(data['data'] ?? data);
    }
    return null;
  }

  Future<void> deleteOrder(int id) async {
    try {
      await _provider.deleteOrder(id);
    } catch (_) {}
  }

  Future<void> deleteOrderItem(int orderId, int itemId) async {
    try {
      await _provider.deleteOrderItem(orderId, itemId);
    } catch (_) {}
  }
}
