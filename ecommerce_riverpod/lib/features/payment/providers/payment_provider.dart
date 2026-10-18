import 'dart:async';
import 'package:dart_payway/dart_payway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/constants/api_constants.dart';
import '../../../app/data/models/order.model.dart';
import '../../../app/data/repository/order_repository.dart';

import '../../admin/presentation/providers/admin_provider.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';

class PaymentState {
  final bool isLoading;
  final bool isVerifying;
  final bool isPaid;
  final String? errorMessage;
  final String tranId;
  final String pageTitle;
  final OrderRes? placedOrder;

  const PaymentState({
    this.isLoading = true,
    this.isVerifying = false,
    this.isPaid = false,
    this.errorMessage,
    this.tranId = '',
    this.pageTitle = 'ABA PayWay',
    this.placedOrder,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isVerifying,
    bool? isPaid,
    String? errorMessage,
    String? tranId,
    String? pageTitle,
    OrderRes? placedOrder,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      isPaid: isPaid ?? this.isPaid,
      errorMessage: errorMessage,
      tranId: tranId ?? this.tranId,
      pageTitle: pageTitle ?? this.pageTitle,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }
}

class PaymentNotifier extends AutoDisposeNotifier<PaymentState> {
  late final PaywayTransactionService _service;
  Timer? _pollingTimer;

  @override
  PaymentState build() {
    _service = PaywayTransactionService(
      merchant: PaywayMerchant(
        merchantID: kMerchantID,
        merchantApiName: kMerchantName,
        merchantApiKey: kMerchantApiKey,
        baseApiUrl: kBaseUrl,
        refererDomain: kRefererDomain,
      ),
    );

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return const PaymentState();
  }

  PaywayTransactionService get service => _service;

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setTranId(String id) {
    state = state.copyWith(tranId: id);
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void startPolling({
    required int? addressId,
    String? notes,
  }) {
    stopPolling();
    int attempts = 0;
    int consecutiveFailures = 0;
    const maxAttempts = 60; // 4 minutes timeout
    const maxConsecutiveFailures = 5;

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      attempts++;
      if (attempts >= maxAttempts) {
        stopPolling();
        state = state.copyWith(
          errorMessage:
              'Payment verification timed out. Please check your transaction.',
        );
        return;
      }

      try {
        final success = await checkPaymentStatus(
          addressId: addressId,
          notes: notes,
        );
        if (success) {
          stopPolling();
        }
        consecutiveFailures = 0;
      } catch (e) {
        consecutiveFailures++;
        if (consecutiveFailures >= maxConsecutiveFailures) {
          stopPolling();
          state = state.copyWith(
            errorMessage:
                'Unable to reach PayWay gateway. Please check your internet connection.',
          );
        }
      }
    });
  }

  Future<bool> checkPaymentStatus({
    required int? addressId,
    String? notes,
  }) async {
    if (state.tranId.isEmpty || state.isVerifying || state.isPaid) return false;

    state = state.copyWith(isVerifying: true);
    try {
      final response = await _service.checkTransaction(
        transaction: PaywayCheckTransaction(
          tranId: state.tranId,
          reqTime: _service.uniqueReqTime(),
        ),
      );

      final isSuccess = response.status == 0;
      if (isSuccess) {
        stopPolling();
        // Place order on server
        OrderRes? order;
        if (addressId != null) {
          try {
            final repo = ref.read(orderRepositoryProvider);
            order = await repo.placeOrder(
              addressId: addressId,
              note: notes,
              paymentMethod: 'aba_payway',
            );
            await ref.read(cartNotifierProvider.notifier).clearCart();
            ref.invalidate(ordersNotifierProvider);
            ref.invalidate(adminNotifierProvider);
          } catch (_) {}
        }

        state = state.copyWith(
          isPaid: true,
          isVerifying: false,
          placedOrder: order,
        );
        return true;
      }
    } catch (e) {
      // Re-throw so polling can track consecutive network failures
      rethrow;
    } finally {
      state = state.copyWith(isVerifying: false);
    }
    return false;
  }

  Future<void> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

final paymentNotifierProvider =
    NotifierProvider.autoDispose<PaymentNotifier, PaymentState>(PaymentNotifier.new);
