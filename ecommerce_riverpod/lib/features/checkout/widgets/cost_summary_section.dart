import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/currency_utils.dart';
import '../../../app/core/utils/l10n_extensions.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class CostSummarySection extends ConsumerWidget {
  const CostSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final subtotal = cartState.subtotal;
    final shippingFee = checkoutState.shippingFee;
    final tax = checkoutState.calculateTax(subtotal);
    final discount = checkoutState.discount;
    final total = checkoutState.calculateTotal(subtotal);
    final count = cartState.itemCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECECF0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.costSummary,
            style: AppFonts.font(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          //  Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.l10n.subTotal} ($count)',
                style: AppFonts.font(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyUtils.format(subtotal),
                style: AppFonts.font(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Delivery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.whiteGloveDelivery,
                style: AppFonts.font(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                shippingFee == 0 ? context.l10n.free : CurrencyUtils.format(shippingFee),
                style: AppFonts.font(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: shippingFee == 0
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          //  Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.tax,
                style: AppFonts.font(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyUtils.format(tax),
                style: AppFonts.font(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          //  Discount

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.discount,
                  style: AppFonts.font(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '-${CurrencyUtils.format(discount)}',
                  style: AppFonts.font(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),


          const SizedBox(height: 16),
          const Divider(color: Color(0xFFECECF0), height: 1),
          const SizedBox(height: 16),

          // Row 5: Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.totalAmount,
                style: AppFonts.font(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyUtils.format(total),
                style: AppFonts.font(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
