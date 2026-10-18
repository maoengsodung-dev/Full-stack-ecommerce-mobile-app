import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';

import '../providers/checkout_provider.dart';
import 'checkout_radio_icon.dart';

class DeliveryMethodSection extends ConsumerWidget {
  const DeliveryMethodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);

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
                    Icons.local_shipping_outlined,
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
                      context.l10n.courierService,
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.handledWithCare,
                      style: AppFonts.font(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.l10n.complimentary,
                  style: AppFonts.font(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...List.generate(CheckoutState.deliveryOptions.length, (index) {
            final option = CheckoutState.deliveryOptions[index];
            final isSelected = state.selectedDeliveryIndex == index;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < CheckoutState.deliveryOptions.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () => notifier.setDeliveryIndex(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.01)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CheckoutRadioIcon(isSelected: isSelected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: AppFonts.font(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.duration,
                              style: AppFonts.font(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            if (option.arrivalNote != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                option.arrivalNote!,
                                style: AppFonts.font(
                                  fontSize: 11,
                                  color: const Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        option.feeLabel,
                        style: AppFonts.font(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: option.fee == 0
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
