import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/address.model.dart';
import 'package:architecture_getx/app/data/models/order.model.dart';
import 'package:architecture_getx/app/data/repository/address_repository.dart';
import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryOption {
  final String title;
  final String duration;
  final double fee;
  final String feeLabel;
  final String? arrivalNote;

  DeliveryOption({
    required this.title,
    required this.duration,
    required this.fee,
    required this.feeLabel,
    this.arrivalNote,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final String maskedNumber;
  final String type; // 'apple_pay', 'cash', etc.

  PaymentMethod({
    required this.id,
    required this.name,
    required this.maskedNumber,
    required this.type,
  });
}

class CheckoutController extends GetxController {
  final OrderRepository _orderRepo;
  final AddressRepository _addrRepo;

  CheckoutController(this._orderRepo, this._addrRepo);

  final isLoading = false.obs;
  final isPlacingOrder = false.obs;
  final isManifestExpanded = true.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rxn<AddressModel>();
  final notesCtrl = TextEditingController();
  final promoCtrl = TextEditingController();
  final appliedPromo = ''.obs;
  final discount = 0.0.obs;
  final placedOrder = Rxn<OrderRes>();

  String get userEmail {
    try {
      if (Get.isRegistered<StorageService>()) {
        final u = Get.find<StorageService>().getUser();
        if (u?.email != null && u!.email!.isNotEmpty) {
          return u.email!;
        }
      }
    } catch (_) {}
    return 'customer@atelier.com';
  }

  // Payment methods matching design (Apple Pay & Cash Payment)
  final selectedPaymentIndex = 0.obs;
  final paymentMethods = [
    PaymentMethod(
      id: 'apple_pay',
      name: 'Apple Pay',
      maskedNumber: 'Mastercard ending in 8492',
      type: 'apple_pay',
    ),
    PaymentMethod(
      id: 'cash',
      name: 'Cash Payment',
      maskedNumber: 'I will paid with delivery',
      type: 'cash',
    ),
  ];

  // Delivery options matching design (Express Delivery selected as in screenshot)
  final selectedDeliveryIndex = 1.obs;
  final deliveryOptions = [
    DeliveryOption(
      title: 'Standard Delivery',
      duration: '3–5 Business Days | Fully Tracked',
      fee: 0.0,
      feeLabel: 'Free',
    ),
    DeliveryOption(
      title: 'Express Delivery',
      duration: 'Next Day Delivery | Priority Courier',
      fee: 25.0,
      feeLabel: '\$25.00',
      arrivalNote: 'Arriving Tomorrow by 2:00 PM',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final list = await _addrRepo.getAddresses();
      addresses.assignAll(list);
      // Auto-select default
      selectedAddress.value =
          list.firstWhereOrNull((a) => a.isDefault) ?? list.firstOrNull;
    } catch (_) {
      // Keep empty if failed to fetch
    } finally {
      isLoading.value = false;
    }
  }

  void applyPromo() {
    final code = promoCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    if (code == 'NEORA' || code == 'DISCOUNT10' || code == 'SAVE') {
      appliedPromo.value = code;
      discount.value = 20.0;
      Get.snackbar(
        'Promo Applied',
        'Promo code $code applied successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111111),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Invalid Code',
        'The promo code entered is not valid',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double get subtotal {
    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>().cart.value;
      return cart?.subtotal ?? 0.0;
    }
    return 0.0;
  }

  double get shippingFee {
    if (selectedDeliveryIndex.value >= 0 &&
        selectedDeliveryIndex.value < deliveryOptions.length) {
      return deliveryOptions[selectedDeliveryIndex.value].fee;
    }
    return 0.0;
  }

  double get estimatedTax {
    return subtotal * 0.08; // 8% estimated tax
  }

  double get total {
    final t = subtotal + shippingFee + estimatedTax - discount.value;
    return t > 0 ? t : 0.0;
  }

  Future<void> onPlaceOrder() async {
    if (selectedAddress.value == null) {
      Get.snackbar(
        'Address Required',
        'Please select a delivery address before placing your order.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Apple Pay / PayWay gateway
    if (selectedPaymentIndex.value == 0) {
      final addr = selectedAddress.value;
      final recipient = (addr?.recipientName != null && addr!.recipientName.isNotEmpty)
          ? addr.recipientName
          : (Get.isRegistered<StorageService>()
              ? (Get.find<StorageService>().getUser()?.name ?? '')
              : '');
      final nameParts = recipient.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'Customer';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      Get.toNamed(
        Routes.ABA_PAYWAY,
        arguments: {
          'price': total,
          'title': 'Apple Pay',
          'addressId': addr?.id,
          'notes': notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
          'firstname': firstName,
          'lastname': lastName,
          'phone': addr?.phone ?? '',
        },
      );
      return;
    }

    // Cash on Delivery — place the order directly
    try {
      isPlacingOrder.value = true;
      final address = selectedAddress.value;
      if (address == null) return;

      final noteText = notesCtrl.text.trim();
      final order = await _orderRepo.placeOrder(
        addressId: address.id,
        note: noteText.isNotEmpty ? noteText : null,
        paymentMethod: 'cod',
      );
      placedOrder.value = order;

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().clearCart();
      }

      Get.offNamed(
        Routes.ORDER_SUCCESS,
        arguments: {'order': order, 'paymentMethod': 'Cash on Delivery'},
      );
    } catch (e) {
      Get.snackbar(
        'Order Failed',
        'Could not place order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  @override
  void onClose() {
    notesCtrl.dispose();
    promoCtrl.dispose();
    super.onClose();
  }
}
