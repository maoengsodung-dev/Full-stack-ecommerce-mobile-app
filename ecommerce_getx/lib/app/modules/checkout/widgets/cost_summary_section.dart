import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/checkout_controller.dart';

class CostSummarySection extends StatelessWidget {
  const CostSummarySection({
    super.key,
    required this.controller,
    required this.itemsCount,
    required this.formatter,
  });

  final CheckoutController controller;
  final int itemsCount;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = itemsCount;

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
            // Title
            Text(
              context.l10n.costSummary,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 16),

            // Row 1: Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.l10n.subTotal} ($count)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF555555),
                  ),
                ),
                Text(
                  formatter.format(controller.subtotal),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Delivery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.whiteGloveDelivery,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF555555),
                  ),
                ),
                if (controller.shippingFee == 0.0)
                  Text(
                    context.l10n.free,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4D7C0F),
                    ),
                  )
                else
                  Text(
                    formatter.format(controller.shippingFee),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111111),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Estimated Tax & Surcharge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.estimatedTaxSurcharge,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF888888),
                    ),
                  ],
                ),
                Text(
                  formatter.format(controller.estimatedTax),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),

            if (controller.discount.value > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.privilegeDiscount,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  Text(
                    '-${formatter.format(controller.discount.value)}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECECF0), height: 1),
            const SizedBox(height: 16),

            // Row 4: Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  context.l10n.totalAmount,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
                Text(
                  formatter.format(controller.total),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
