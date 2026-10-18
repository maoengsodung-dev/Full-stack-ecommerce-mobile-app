import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/checkout_controller.dart';
import 'checkout_radio_icon.dart';

class DeliveryMethodSection extends StatelessWidget {
  const DeliveryMethodSection({
    super.key,
    required this.controller,
  });

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            // Header Row: Delivery Van Icon + Courier Service / Atelier Care + Complimentary Badge
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.handledWithCare,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
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
                    color: const Color(0xFFD4F835),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.l10n.complimentary,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF283A00),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delivery Options list
            ...List.generate(controller.deliveryOptions.length, (index) {
              final option = controller.deliveryOptions[index];
              final isSelected = controller.selectedDeliveryIndex.value == index;

              final title = index == 0
                  ? context.l10n.standardDelivery
                  : context.l10n.expressDelivery;
              final duration = index == 0
                  ? context.l10n.standardDeliveryDesc
                  : context.l10n.expressDeliveryDesc;
              final arrivalNote =
                  index == 1 ? context.l10n.arrivingTomorrow : option.arrivalNote;

              return GestureDetector(
                onTap: () => controller.selectedDeliveryIndex.value = index,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: index < controller.deliveryOptions.length - 1 ? 12 : 0,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0267F6)
                          : const Color(0xFFECECF0),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Radio circle
                      CheckoutRadioIcon(isSelected: isSelected),
                      const SizedBox(width: 14),

                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              duration,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            if (arrivalNote != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Color(0xFF4D7C0F),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    arrivalNote,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4D7C0F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Price
                      Text(
                        option.fee == 0.0 ? context.l10n.free : option.feeLabel,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: option.fee == 0.0
                              ? const Color(0xFF4D7C0F)
                              : const Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
