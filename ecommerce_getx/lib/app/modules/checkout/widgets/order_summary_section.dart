import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/checkout_controller.dart';

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({
    super.key,
    required this.controller,
    required this.items,
    required this.formatter,
  });

  final CheckoutController controller;
  final List<dynamic> items;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isManifestExpanded.value;
      final count = items.length;

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
            // Header Row: Inventory Bag Icon + Title & Count + Chevron Toggle
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count ${context.l10n.pieces}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.isManifestExpanded.toggle(),
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

            // Collapsible Item Cards List
            if (isExpanded) ...[
              const SizedBox(height: 16),
              if (items.isNotEmpty)
                ...items.map((item) => _buildCartItemCard(context, item))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      context.l10n.yourShoppingBagIsEmpty,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCartItemCard(BuildContext context, dynamic item) {
    final color = item.variant?.color ?? '';
    final size = item.variant?.size ?? '';
    final tag = item.product?.category?.name ?? '';

    final metaDetails = [
      if (color.isNotEmpty) color,
      if (size.isNotEmpty) size,
      '${context.l10n.quantity}: ${item.quantity}',
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFECECEF),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.product?.primaryImage?.url != null &&
                    item.product.primaryImage!.url.isNotEmpty
                ? Image.network(
                    item.product.primaryImage!.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.image_outlined,
                          size: 22, color: Color(0xFF999999)),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.checkroom_outlined,
                        size: 22, color: Color(0xFF999999)),
                  ),
          ),
          const SizedBox(width: 14),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? '',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  metaDetails,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF757575),
                  ),
                ),
                if (tag.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECECEF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Price
          Text(
            formatter.format(item.total),
            style: GoogleFonts.playfairDisplay(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
