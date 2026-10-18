import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/checkout_controller.dart';
import 'checkout_radio_icon.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
    required this.controller,
  });

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedPaymentIndex.value;

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
            // Header Row: Credit Card Icon + Title & Subtitle
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.defaultBilling,
                        style: GoogleFonts.inter(
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

            // Option 0: Apple Pay
            GestureDetector(
              onTap: () => controller.selectedPaymentIndex.value = 0,
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == 0
                        ? const Color(0xFF0267F6)
                        : const Color(0xFFECECF0),
                    width: selected == 0 ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Apple Pay Badge
                    Container(
                      width: 44,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.apple,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Pay',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Label & Masked Number
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apple Pay',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mastercard ending in 8492',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Radio
                    CheckoutRadioIcon(isSelected: selected == 0),
                  ],
                ),
              ),
            ),

            // Option 1: Cash Payment
            GestureDetector(
              onTap: () => controller.selectedPaymentIndex.value = 1,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == 1
                        ? const Color(0xFF0267F6)
                        : const Color(0xFFECECF0),
                    width: selected == 1 ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Cash Icon Badge (Lime Circle with Star / Dollar Icon)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4F835),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.stars_rounded,
                          size: 20,
                          color: Color(0xFF283A00),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Label & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.cashOnDelivery,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'I will paid with delivery',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Radio
                    CheckoutRadioIcon(isSelected: selected == 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
