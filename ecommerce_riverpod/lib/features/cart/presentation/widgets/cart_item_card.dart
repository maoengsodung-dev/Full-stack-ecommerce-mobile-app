import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/constants/asset_constants.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/data/models/cart.model.dart';
import '../providers/cart_provider.dart';
import 'quantity_control.dart';

class CartItemCard extends ConsumerWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.formatter,
  });

  final CartItem item;
  final NumberFormat formatter;

  double get unitPrice {
    if (item.price > 0) return item.price;
    if (item.product.effectivePrice > 0) return item.product.effectivePrice;
    return item.product.price;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalPrice = item.product.price > unitPrice
        ? item.product.price
        : unitPrice * 1.15;
    final hasDiscount = originalPrice > unitPrice;
    final colorLabel = item.variant?.color ?? 'Null';
    final sizeLabel = item.variant?.size ?? 'Null';
    final isLowStock = item.product.stock <= 5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 104,
            height: 114,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4F0),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: item.product.primaryImage?.url != null &&
                          item.product.primaryImage!.url.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.product.primaryImage!.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              SvgPicture.asset(AssetConstants.cart),
                        )
                      : Center(
                          child: SvgPicture.asset(
                            AssetConstants.cart,
                            color: AppColors.accentBlue,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppFonts.font(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(cartNotifierProvider.notifier)
                            .removeItem(item.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        colorLabel,
                        style: AppFonts.font(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Size $sizeLabel',
                        style: AppFonts.font(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF84CC16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLowStock ? 'Low Stock' : 'In Stock',
                          style: AppFonts.font(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${unitPrice.toStringAsFixed(2)}',
                          style: AppFonts.font(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 18.5,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: AppFonts.font(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    QuantityControl(item: item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
