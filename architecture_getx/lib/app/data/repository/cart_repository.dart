import '../models/cart.model.dart';
import '../providers/cart_provider.dart';

class CartRepository {
  final CartProvider _provider;

  CartRepository(this._provider);

  Future<CartRes> getCart() async {
    final response = await _provider.getCart();
    final data = response.data;
    return CartRes.fromJson(data['data'] ?? data);
  }

  Future<dynamic> addItem(int productId, int quantity, {int? variantId}) async {
    final response = await _provider.addItem(productId, quantity, variantId: variantId);
    return response.data;
  }

  Future<dynamic> updateItem(int itemId, int quantity) async {
    final response = await _provider.updateItem(itemId, quantity);
    return response.data;
  }

  Future<void> removeItem(int itemId) async {
    await _provider.removeItem(itemId);
  }

  Future<void> clearCart() async {
    await _provider.clearCart();
  }
}
