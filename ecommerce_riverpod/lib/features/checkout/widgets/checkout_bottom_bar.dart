import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class CheckoutBottomBar extends ConsumerWidget {
  const CheckoutBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final cartState = ref.watch(cartNotifierProvider);
    final isPlacing = state.isPlacingOrder;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 8
            : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor:AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: isPlacing
              ? null
              : () async {
                  if (state.selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a delivery address.'),
                      ),
                    );
                    return;
                  }

                  final total = state.calculateTotal(cartState.subtotal);

                  // Online Payment (ABA PayWay / Cards)
                  if (state.selectedPaymentIndex == 0) {
                    Navigator.of(context).pushNamed(
                      RouteNames.payment,
                      arguments: {
                        'price': total,
                        'title': 'Online Payment',
                        'addressId': state.selectedAddress?.id,
                        'notes': state.notes,
                        'firstname':
                            state.selectedAddress?.recipientName ?? 'Customer',
                        'lastname': '',
                        'phone': state.selectedAddress?.phone ?? '',
                      },
                    );
                    return;
                  }

                  // Cash on Delivery
                  try {
                    final order = await notifier.placeOrder();
                    if (context.mounted && order != null) {
                      await ref.read(cartNotifierProvider.notifier).clearCart();
                      Navigator.of(context).pushReplacementNamed(
                        RouteNames.orderSuccess,
                        arguments: {
                          'order': order,
                          'paymentMethod': 'Cash on Delivery',
                        },
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order failed: $e')),
                      );
                    }
                  }
                },
          child: isPlacing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  context.l10n.placeOrder,
                  style: AppFonts.font(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
        ),
      ),
    );
  }
}
