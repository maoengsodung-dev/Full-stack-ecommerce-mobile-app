import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:architecture_getx/app/data/models/cart.model.dart';
import '../../../core/constants/asset_constants.dart';
import '../controllers/cart_controller.dart';
import 'quantity_control.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.formatter,
  });

  final CartItem item;
  final CartController controller;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final originalPrice = item.product.price > unitPrice
        ? item.product.price
        : unitPrice * 1.15;
    final hasDiscount = originalPrice > unitPrice;
    final colorLabel = item.variant?.color ?? 'Pale Ecru';
    final sizeLabel = item.variant?.size ?? 'M';
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
          // Product Image with "02 EDITION" pill
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
                  child:
                      item.product.primaryImage?.url != null &&
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

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Remove X Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removeItem(item.id),
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

                // Chips Row: Color, Size, Stock status
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Color chip
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
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    // Size chip
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
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    // Low Stock Indicator
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
                          style: GoogleFonts.inter(
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

                // Price and Quantity Stepper
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${unitPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 18.5,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Stepper
                    QuantityControl(item: item, controller: controller),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get unitPrice {
    if (item.price > 0) return item.price;
    if (item.product.effectivePrice > 0) return item.product.effectivePrice;
    return item.product.price;
  }
}
