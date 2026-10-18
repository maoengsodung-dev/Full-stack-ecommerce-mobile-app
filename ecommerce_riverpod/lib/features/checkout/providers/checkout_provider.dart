import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/address.model.dart';
import '../../../app/data/models/order.model.dart';
import '../../../app/data/repository/address_repository.dart';
import '../../../app/data/repository/order_repository.dart';
import '../../admin/presentation/providers/admin_provider.dart';
import '../../orders/providers/order_provider.dart';

class DeliveryOption {
  final String title;
  final String duration;
  final double fee;
  final String feeLabel;
  final String? arrivalNote;

  const DeliveryOption({
    required this.title,
    required this.duration,
    required this.fee,
    required this.feeLabel,
    this.arrivalNote,
  });
}

class PaymentMethodItem {
  final String id;
  final String name;
  final String maskedNumber;
  final String type;

  const PaymentMethodItem({
    required this.id,
    required this.name,
    required this.maskedNumber,
    required this.type,
  });
}

class CheckoutState {
  final AsyncValue<List<AddressModel>> addresses;
  final AddressModel? selectedAddress;
  final int selectedDeliveryIndex;
  final int selectedPaymentIndex;
  final String notes;
  final String appliedPromo;
  final double discount;
  final bool isPlacingOrder;
  final bool isManifestExpanded;

  static const List<DeliveryOption> deliveryOptions = [
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

  static const List<PaymentMethodItem> paymentMethods = [
    PaymentMethodItem(
      id: 'apple_pay',
      name: 'Apple Pay',
      maskedNumber: 'Mastercard ending in 8492',
      type: 'apple_pay',
    ),
    PaymentMethodItem(
      id: 'cash',
      name: 'Cash Payment',
      maskedNumber: 'I will pay with delivery',
      type: 'cash',
    ),
  ];

  const CheckoutState({
    this.addresses = const AsyncValue.loading(),
    this.selectedAddress,
    this.selectedDeliveryIndex = 1,
    this.selectedPaymentIndex = 0,
    this.notes = '',
    this.appliedPromo = '',
    this.discount = 0.0,
    this.isPlacingOrder = false,
    this.isManifestExpanded = true,
  });

  double get shippingFee {
    if (selectedDeliveryIndex >= 0 && selectedDeliveryIndex < deliveryOptions.length) {
      return deliveryOptions[selectedDeliveryIndex].fee;
    }
    return 0.0;
  }

  double calculateTax(double subtotal) => subtotal * 0.08;

  double calculateTotal(double subtotal) {
    final t = subtotal + shippingFee + calculateTax(subtotal) - discount;
    return t > 0 ? t : 0.0;
  }

  CheckoutState copyWith({
    AsyncValue<List<AddressModel>>? addresses,
    AddressModel? Function()? selectedAddress,
    int? selectedDeliveryIndex,
    int? selectedPaymentIndex,
    String? notes,
    String? appliedPromo,
    double? discount,
    bool? isPlacingOrder,
    bool? isManifestExpanded,
  }) {
    return CheckoutState(
      addresses: addresses ?? this.addresses,
      selectedAddress:
          selectedAddress != null ? selectedAddress() : this.selectedAddress,
      selectedDeliveryIndex:
          selectedDeliveryIndex ?? this.selectedDeliveryIndex,
      selectedPaymentIndex: selectedPaymentIndex ?? this.selectedPaymentIndex,
      notes: notes ?? this.notes,
      appliedPromo: appliedPromo ?? this.appliedPromo,
      discount: discount ?? this.discount,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      isManifestExpanded: isManifestExpanded ?? this.isManifestExpanded,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    Future.microtask(() => fetchAddresses());
    return const CheckoutState();
  }

  Future<void> fetchAddresses() async {
    state = state.copyWith(addresses: const AsyncValue.loading());
    try {
      final repo = ref.read(addressRepositoryProvider);
      final list = await repo.getAddresses();
      final defaultAddr =
          list.where((a) => a.isDefault).firstOrNull ?? list.firstOrNull;
      state = state.copyWith(
        addresses: AsyncValue.data(list),
        selectedAddress: () => defaultAddr,
      );
    } catch (e, st) {
      state = state.copyWith(addresses: AsyncValue.error(e, st));
    }
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: () => address);
  }

  void setDeliveryIndex(int index) {
    state = state.copyWith(selectedDeliveryIndex: index);
  }

  void setPaymentIndex(int index) {
    state = state.copyWith(selectedPaymentIndex: index);
  }

  void toggleManifest() {
    state = state.copyWith(isManifestExpanded: !state.isManifestExpanded);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  bool applyPromo(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed == 'NEORA' || trimmed == 'DISCOUNT10' || trimmed == 'SAVE') {
      state = state.copyWith(
        appliedPromo: trimmed,
        discount: 20.0,
      );
      return true;
    }
    return false;
  }

  Future<OrderRes?> placeOrder() async {
    final addr = state.selectedAddress;
    if (addr == null) return null;

    state = state.copyWith(isPlacingOrder: true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final order = await repo.placeOrder(
        addressId: addr.id,
        note: state.notes.isNotEmpty ? state.notes : null,
        paymentMethod: state.selectedPaymentIndex == 0 ? 'online' : 'cod',
      );
      state = state.copyWith(isPlacingOrder: false);
      ref.invalidate(ordersNotifierProvider);
      ref.invalidate(adminNotifierProvider);
      return order;
    } catch (e) {
      state = state.copyWith(isPlacingOrder: false);
      rethrow;
    }
  }
}

final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
