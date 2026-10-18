import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/cart_controller.dart';

class CartSummary extends StatefulWidget {
  const CartSummary({
    super.key,
    required this.controller,
    required this.formatter,
  });

  final CartController controller;
  final NumberFormat formatter;

  @override
  State<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary> {
  final TextEditingController _voucherInputController = TextEditingController();

  @override
  void dispose() {
    _voucherInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //  Atelier Privilege Code Card
        _buildPrivilegeCard(),
        const SizedBox(height: 16),

        // Order Summary Card
        _buildOrderSummaryCard(),
      ],
    );
  }

  // Privilege Voucher Card

  Widget _buildPrivilegeCard() {
    // final isApplied = widget.controller.isPromoApplied.value;
    // final code = widget.controller.promoCode.value;
    // final discountPercent =
    //     (widget.controller.promoDiscountPercent.value * 100).toInt();

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F1EC),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Active Voucher Pill
            // if (isApplied) ...[
            //   const SizedBox(height: 14),
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 14,
            //       vertical: 8,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(30),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withValues(alpha: 0.02),
            //           blurRadius: 8,
            //           offset: const Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: Row(
            //       children: [
            //         // Lime green indicator dot
            //         Container(
            //           width: 8,
            //           height: 8,
            //           decoration: const BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: Color(0xFF84CC16),
            //           ),
            //         ),
            //         const SizedBox(width: 8),
            //
            //         // Code name
            //         Text(
            //           code,
            //           style: GoogleFonts.inter(
            //             fontSize: 14,
            //             fontWeight: FontWeight.w800,
            //             color: const Color(0xFF0F172A),
            //           ),
            //         ),
            //         const SizedBox(width: 10),
            //
            //         // Discount badge
            //         Container(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 10,
            //             vertical: 3.5,
            //           ),
            //           decoration: BoxDecoration(
            //             color: const Color(0xFFF1F5F9),
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //           child: Text(
            //             '$discountPercent% VIP\nDISCOUNT',
            //             textAlign: TextAlign.center,
            //             style: GoogleFonts.inter(
            //               fontSize: 8.5,
            //               fontWeight: FontWeight.w800,
            //               color: const Color(0xFF334155),
            //               height: 1.1,
            //               letterSpacing: 0.2,
            //             ),
            //           ),
            //         ),
            //         const Spacer(),
            //
            //         // Remove X button
            //         GestureDetector(
            //           onTap: widget.controller.removePromo,
            //           behavior: HitTestBehavior.opaque,
            //           child: Container(
            //             width: 26,
            //             height: 26,
            //             decoration: const BoxDecoration(
            //               color: Color(0xFFF1F5F9),
            //               shape: BoxShape.circle,
            //             ),
            //             child: const Center(
            //               child: Icon(
            //                 Icons.close_rounded,
            //                 size: 14,
            //                 color: Color(0xFF64748B),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

            // Input field + Apply button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherInputController,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Have another gift voucher?',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Apply button
                GestureDetector(
                  onTap: () {
                    final text = _voucherInputController.text;
                    if (text.trim().isNotEmpty) {
                      widget.controller.applyPromo(text);
                      _voucherInputController.clear();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E232A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'APPLY',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Order Summary Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    return Obx(() {
      final subtotal = widget.controller.subtotal;
      // final discount = widget.controller.promoDiscount;
      final tax = widget.controller.taxAmount;
      final total = widget.controller.grandTotal;
      // final isPromoActive = widget.controller.isPromoApplied.value;
      // final promoCode = widget.controller.promoCode.value;
      final itemCount = widget.controller.itemCount;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Order Summary + USD STANDARD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'USD\nSTANDARD',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                    height: 1.15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // : Subtotal
            _summaryRow(
              label: 'Subtotal ($itemCount ${itemCount == 1 ? "item" : "items"})',
              value: '\$${subtotal.toStringAsFixed(2)}',
              isBoldValue: true,
            ),
            const SizedBox(height: 14),

            /// Promotional Benefit (if active)
            // if (isPromoActive && discount > 0) ...[
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           const Icon(
            //             Icons.local_offer_outlined,
            //             size: 14,
            //             color: Color(0xFF4D7C0F),
            //           ),
            //           const SizedBox(width: 6),
            //           Text(
            //             'Promotional Benefit ($promoCode)',
            //             style: GoogleFonts.inter(
            //               fontSize: 13,
            //               color: const Color(0xFF4D7C0F),
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Text(
            //         '-\$${discount.toStringAsFixed(2)}',
            //         style: GoogleFonts.inter(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w700,
            //           color: const Color(0xFF4D7C0F),
            //         ),
            //       ),
            //     ],
            //   ),
            //   const SizedBox(height: 14),
            // ],

            // Line 3: White Glove Courier Delivery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'White Glove Courier',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Delivery',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                       "\$1.50 " ,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'COMPLIMENTARY',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1D4ED8),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Line 4: Estimated Atelier Tax & Surcharge
            _summaryRow(
              label: 'Estimated Atelier Tax & Surcharge',
              value: '\$${tax.toStringAsFixed(2)}',
              isBoldValue: true,
            ),
            const SizedBox(height: 22),

            // Line 5: Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duties and carbon offset\nincluded',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryRow({
    required String label,
    required String value,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
