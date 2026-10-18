import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';

import '../providers/checkout_provider.dart';
import 'checkout_radio_icon.dart';

class PaymentMethodSection extends ConsumerWidget {
  const PaymentMethodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final selected = state.selectedPaymentIndex;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECECF0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 20,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.paymentMethod,
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.defaultBilling,
                      style: AppFonts.font(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Option 0: Online Payment / Card
          GestureDetector(
            onTap: () => notifier.setPaymentIndex(0),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected == 0
                      ? AppColors.primary
                      : const Color(0xFFECECF0),
                  width: selected == 0 ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SvgPicture.asset(AssetConstants.mastercard,width: 60,height: 60,),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Online Payment (ABA PayWay)',
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cards, KHQR, ABA Mobile',
                          style: AppFonts.font(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckoutRadioIcon(isSelected: selected == 0),
                ],
              ),
            ),
          ),

          // Option 1: Cash on Delivery
          GestureDetector(
            onTap: () => notifier.setPaymentIndex(1),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected == 1
                      ? AppColors.primary
                      : const Color(0xFFECECF0),
                  width: selected == 1 ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(AssetConstants.cash,width: 30,height: 30,),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash on Delivery',
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pay in cash upon delivery',
                          style: AppFonts.font(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckoutRadioIcon(isSelected: selected == 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
