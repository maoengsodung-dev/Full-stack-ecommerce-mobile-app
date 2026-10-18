import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/data/models/cart.model.dart';
import '../../../../app/data/models/product.model.dart';
import '../../../../app/data/repository/cart_repository.dart';

class CartState {
  final AsyncValue<CartRes> cart;
  final bool isPromoApplied;
  final String promoCode;
  final double promoDiscountPercent;

  const CartState({
    this.cart = const AsyncValue.loading(),
    this.isPromoApplied = true,
    this.promoCode = 'FALL20',
    this.promoDiscountPercent = 0.20,
  });

  CartRes? get cartData => cart.valueOrNull;

  List<CartItem> get items => cartData?.items ?? const [];

  int get itemCount {
    final current = cartData;
    if (current == null) return 0;
    if (current.items.isNotEmpty) {
      return current.items.fold<int>(0, (sum, item) => sum + item.quantity);
    }
    return current.itemsCount;
  }

  double get subtotal {
    final current = cartData;
    if (current != null && current.subtotal > 0) return current.subtotal;
    if (current != null && current.items.isNotEmpty) {
      return current.items.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
    }
    return 0.0;
  }

  double get deliveryFee => 0.0;

  double get taxAmount {
    if (subtotal <= 0) return 0.0;
    return subtotal * 0.072;
  }

  double get grandTotal {
    if (subtotal <= 0) return 0.0;
    final total = subtotal + deliveryFee + taxAmount;
    return total > 0 ? total : 0.0;
  }

  double get total => grandTotal > 0 ? grandTotal : (cartData?.total ?? 0);

  CartState copyWith({
    AsyncValue<CartRes>? cart,
    bool? isPromoApplied,
    String? promoCode,
    double? promoDiscountPercent,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isPromoApplied: isPromoApplied ?? this.isPromoApplied,
      promoCode: promoCode ?? this.promoCode,
      promoDiscountPercent:
          promoDiscountPercent ?? this.promoDiscountPercent,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    Future.microtask(() => fetchCart(showLoading: false));
    return const CartState();
  }

  Future<void> fetchCart({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(cart: const AsyncValue.loading());
    }
    try {
      final repo = ref.read(cartRepositoryProvider);
      final remoteCart = await repo.getCart();
      state = state.copyWith(cart: AsyncValue.data(remoteCart));
    } catch (e, st) {
      if (state.cart.valueOrNull == null) {
        state = state.copyWith(cart: AsyncValue.error(e, st));
      }
    }
  }

  void applyPromo(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      isPromoApplied: true,
      promoCode: trimmed,
      promoDiscountPercent: trimmed == 'FALL20' ? 0.20 : 0.15,
    );
  }

  void removePromo() {
    state = state.copyWith(isPromoApplied: false);
  }

  Future<bool> addItem(
    int productId, {
    int quantity = 1,
    ProductRes? product,
    int? variantId,
  }) async {
    final currentCart = state.cartData;
    final existingIndex = currentCart?.items.indexWhere(
          (item) =>
              (item.product.id == productId || item.id == productId) &&
              item.productVariantId == variantId,
        ) ??
        -1;

    List<CartItem> updatedItems = [];

    if (currentCart != null) {
      updatedItems = List<CartItem>.from(currentCart.items);
      if (existingIndex >= 0) {
        final existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          price: existingItem.price,
          productVariantId: variantId,
          variant: existingItem.variant,
        );
      } else if (product != null) {
        final resolvedPrice = product.effectivePrice > 0
            ? product.effectivePrice
            : product.price;
        updatedItems.insert(
          0,
          CartItem(
            id: -DateTime.now().millisecondsSinceEpoch,
            product: product,
            quantity: quantity,
            price: resolvedPrice,
            productVariantId: variantId,
          ),
        );
      }
    } else if (product != null) {
      final resolvedPrice = product.effectivePrice > 0
          ? product.effectivePrice
          : product.price;
      updatedItems = [
        CartItem(
          id: -DateTime.now().millisecondsSinceEpoch,
          product: product,
          quantity: quantity,
          price: resolvedPrice,
          productVariantId: variantId,
        ),
      ];
    }

    if (updatedItems.isNotEmpty) {
      final newSubtotal = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final shipping = currentCart?.shippingFee ?? 0.0;
      final newTotal = newSubtotal + shipping;

      state = state.copyWith(
        cart: AsyncValue.data(
          CartRes(
            items: updatedItems,
            subtotal: newSubtotal,
            shippingFee: shipping,
            total: newTotal,
            itemsCount: updatedItems.length,
          ),
        ),
      );
    }

    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.addItem(productId, quantity, variantId: variantId);
      await fetchCart(showLoading: false);
      return true;
    } catch (_) {
      await fetchCart(showLoading: false);
      return false;
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final currentCart = state.cartData;
    if (currentCart != null) {
      final updatedItems = currentCart.items.map((item) {
        if (item.id == itemId) {
          return CartItem(
            id: item.id,
            product: item.product,
            quantity: quantity,
            price: item.price,
            productVariantId: item.productVariantId,
            variant: item.variant,
          );
        }
        return item;
      }).toList();

      final newSubtotal = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final newTotal = newSubtotal + currentCart.shippingFee;

      state = state.copyWith(
        cart: AsyncValue.data(
          CartRes(
            items: updatedItems,
            subtotal: newSubtotal,
            shippingFee: currentCart.shippingFee,
            total: newTotal,
            itemsCount: updatedItems.length,
          ),
        ),
      );
    }

    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.updateItem(itemId, quantity);
      await fetchCart(showLoading: false);
    } catch (_) {
      await fetchCart(showLoading: false);
    }
  }

  Future<void> removeItem(int itemId) async {
    final currentCart = state.cartData;
    if (currentCart != null) {
      final updatedItems =
          currentCart.items.where((i) => i.id != itemId).toList();
      final newSubtotal = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      state = state.copyWith(
        cart: AsyncValue.data(
          CartRes(
            items: updatedItems,
            subtotal: newSubtotal,
            shippingFee: currentCart.shippingFee,
            total: newSubtotal + currentCart.shippingFee,
            itemsCount: updatedItems.length,
          ),
        ),
      );
    }

    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.removeItem(itemId);
      await fetchCart(showLoading: false);
    } catch (_) {
      await fetchCart(showLoading: false);
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(
      cart: AsyncValue.data(CartRes.empty()),
    );
    try {
      final repo = ref.read(cartRepositoryProvider);
      await repo.clearCart();
    } catch (_) {}
  }
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
