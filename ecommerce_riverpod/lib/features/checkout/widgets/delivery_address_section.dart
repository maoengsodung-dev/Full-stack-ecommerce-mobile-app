import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../providers/checkout_provider.dart';

class DeliveryAddressSection extends ConsumerWidget {
  const DeliveryAddressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final addr = state.selectedAddress;

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
                    Icons.location_on_outlined,
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
                      context.l10n.deliveryDestination,
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addr != null
                          ? context.l10n.verifiedResidence
                          : context.l10n.noAddressSelected,
                      style: AppFonts.font(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              //  Change address
              GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(RouteNames.addressList);
                  ref.read(checkoutNotifierProvider.notifier).fetchAddresses();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Text(
                    context.l10n.change,
                    style: AppFonts.font(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (addr == null)
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(RouteNames.addressList);
                ref.read(checkoutNotifierProvider.notifier).fetchAddresses();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E2E6),
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_location_alt_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select / Add Delivery Address',
                      style: AppFonts.font(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFECECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        addr.recipientName,
                        style: AppFonts.font(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: AppFonts.font(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addr.fullAddress,
                    style: AppFonts.font(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (addr.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      addr.phone,
                      style: AppFonts.font(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
