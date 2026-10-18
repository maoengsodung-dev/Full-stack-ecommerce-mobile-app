import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/currency_utils.dart';
import '../../../app/core/utils/l10n_extensions.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class OrderSummarySection extends ConsumerWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final cartState = ref.watch(cartNotifierProvider);
    final items = cartState.items;
    final isExpanded = state.isManifestExpanded;

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
                    Icons.inventory_2_outlined,
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
                      context.l10n.orderManifest,
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${items.length} ${context.l10n.pieces}',
                      style: AppFonts.font(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => notifier.toggleManifest(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),
            ...items.map((item) {
              final product = item.product;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: AppColors.background,
                        child: (product?.primaryImage?.url.isNotEmpty == true)
                            ? CachedNetworkImage(
                                imageUrl: product!.primaryImage!.url,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.textHint,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: AppColors.textHint,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Product',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.font(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.quantity}x ${CurrencyUtils.format(item.price)}',
                            style: AppFonts.font(
                              fontSize: 12,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(item.subtotal),
                      style: AppFonts.font(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
