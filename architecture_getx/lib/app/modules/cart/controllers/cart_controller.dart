import 'package:architecture_getx/app/data/models/cart.model.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:architecture_getx/app/data/repository/cart_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartRepository _repo;

  CartController(this._repo);

  final isLoading = false.obs;
  final cart = Rxn<CartRes>();
  final errorMessage = ''.obs;

  final isPromoApplied = true.obs;
  final promoCode = 'FALL20'.obs;
  final promoDiscountPercent = 0.20.obs;

  int get itemCount {
    final current = cart.value;
    if (current == null) return 0;
    if (current.items.isNotEmpty) {
      return current.items.fold<int>(0, (sum, item) => sum + item.quantity);
    }
    return current.itemsCount;
  }

  double get subtotal {
    final current = cart.value;
    if (current != null && current.subtotal > 0) return current.subtotal;
    if (current != null && current.items.isNotEmpty) {
      return current.items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    }
    return 0.0;
  }

  // double get promoDiscount {
  //   if (!isPromoApplied.value) return 0.0;
  //   return subtotal * promoDiscountPercent.value;
  // }

  double get deliveryFee => 0.0; // Complimentary

  double get taxAmount {
    if (subtotal <= 0) return 0.0;
    return (subtotal * 0.072);
  }

  double get grandTotal {
    if (subtotal <= 0) return 0.0;
    final total = subtotal  + deliveryFee + taxAmount;
    return total > 0 ? total : 0.0;
  }

  double get total => grandTotal > 0 ? grandTotal : (cart.value?.total ?? 0);

  void applyPromo(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    isPromoApplied.value = true;
    promoCode.value = trimmed;
    if (trimmed == 'FALL20') {
      promoDiscountPercent.value = 0.20;
    } else {
      promoDiscountPercent.value = 0.15;
    }

    Get.snackbar(
      'Promo Applied',
      '${(promoDiscountPercent.value * 100).toInt()}% VIP Discount applied!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF84CC16),
      colorText: Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  void removePromo() {
    isPromoApplied.value = false;
    Get.snackbar(
      'Promo Removed',
      'Voucher code removed.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchCart(showLoading: false);
  }



  Future<void> fetchCart({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final remoteCart = await _repo.getCart();
      cart.value = remoteCart;
    } on DioException catch (e) {
      if (cart.value == null) {
        errorMessage.value =
            e.response?.data?['message'] ?? 'Failed to load cart';
      }
    } catch (e) {
      if (cart.value == null) {
        errorMessage.value = e.toString();
      }
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<bool> addItem(
    int productId, {
    int quantity = 1,
    ProductRes? product,
    int? variantId,
  }) async {
    // Optimistic update for instant UI feedback
    final currentCart = cart.value;
    final existingIndex = currentCart?.items.indexWhere(
      (item) => (item.product.id == productId || item.id == productId) && item.productVariantId == variantId,
    ) ?? -1;

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

      cart.value = CartRes(
        items: updatedItems,
        subtotal: newSubtotal,
        shippingFee: shipping,
        total: newTotal,
        itemsCount: updatedItems.length,
      );
    }

    // 2. Persist to API & sync in background
    try {
      await _repo.addItem(productId, quantity, variantId: variantId);
      await fetchCart(showLoading: false);
      return true;
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to add item',
        snackPosition: SnackPosition.TOP,
      );
      await fetchCart(showLoading: false); // Revert on failure
      return false;
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

    // 1. Optimistic update for instant UI feedback
    final currentCart = cart.value;
    if (currentCart != null) {
      final updatedItems = currentCart.items.map((item) {
        if (item.id == itemId) {
          return CartItem(
            id: item.id,
            product: item.product,
            quantity: quantity,
            price: item.price,
          );
        }
        return item;
      }).toList();

      final newSubtotal = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final newTotal = newSubtotal + currentCart.shippingFee;

      cart.value = CartRes(
        items: updatedItems,
        subtotal: newSubtotal,
        shippingFee: currentCart.shippingFee,
        total: newTotal,
        itemsCount: updatedItems.length,
      );
    }

    // 2. Persist to API & sync in background
    try {
      await _repo.updateItem(itemId, quantity);
      await fetchCart(showLoading: false);
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to update',
        snackPosition: SnackPosition.TOP,
      );
      await fetchCart(showLoading: false); // Revert on failure
    } catch (_) {
      await fetchCart(showLoading: false);
    }
  }

  Future<void> removeItem(int itemId) async {
    // 1. Optimistic removal
    final currentCart = cart.value;
    if (currentCart != null) {
      final updatedItems = currentCart.items
          .where((item) => item.id != itemId)
          .toList();
      final newSubtotal = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final newTotal = newSubtotal + currentCart.shippingFee;

      cart.value = CartRes(
        items: updatedItems,
        subtotal: newSubtotal,
        shippingFee: currentCart.shippingFee,
        total: newTotal,
        itemsCount: updatedItems.length,
      );
    }

    // 2. Call delete API & sync
    try {
      await _repo.removeItem(itemId);
      await fetchCart(showLoading: false);
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to remove',
        snackPosition: SnackPosition.TOP,
      );
      await fetchCart(showLoading: false);
    }
  }

  Future<void> clearCart() async {
    cart.value = CartRes.empty();
    try {
      await _repo.clearCart();
    } catch (e) {
      debugPrint('[CartController] clearCart error: $e');
    }
  }

  // Increase item quantity by 1
  Future<void> increaseQuantity(int itemId, [int? currentQuantity]) async {
    try {
      final current =
          currentQuantity ??
          cart.value?.items
              .firstWhereOrNull((item) => item.id == itemId)
              ?.quantity ??
          1;
      await updateQuantity(itemId, current + 1);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Decrease item quantity
  Future<void> decreaseQuantity(int itemId, [int? currentQuantity]) async {
    final current =
        currentQuantity ??
        cart.value?.items
            .firstWhereOrNull((item) => item.id == itemId)
            ?.quantity ??
        1;
    if (current <= 1) {
      await removeItem(itemId);
    } else {
      await updateQuantity(itemId, current - 1);
    }
  }
}
