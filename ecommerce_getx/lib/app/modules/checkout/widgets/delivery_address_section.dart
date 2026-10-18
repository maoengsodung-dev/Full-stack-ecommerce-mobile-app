import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:architecture_getx/app/routes/app_pages.dart';
import '../controllers/checkout_controller.dart';

class DeliveryAddressSection extends StatelessWidget {
  const DeliveryAddressSection({
    super.key,
    required this.controller,
  });

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final addr = controller.selectedAddress.value;

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
            // Header Row: Icon + Title/Subtitle + Change Link
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr != null
                            ? context.l10n.verifiedResidence
                            : context.l10n.noAddressSelected,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(
                      context.l10n.change,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0267F6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (addr == null)
              GestureDetector(
                onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFECECF0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECECEF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_location_alt_outlined,
                          size: 18,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.pleaseAddAddress,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF888888),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Inner Address Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Label Badge
                    Row(
                      children: [
                        Text(
                          addr.recipientName.isNotEmpty
                              ? addr.recipientName
                              : 'Recipient',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        if (addr.label.isNotEmpty) ...[
                          const SizedBox(width: 8),
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
                              addr.label,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF283A00),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Street & City / Postal
                    Text(
                      '${addr.address}${addr.city.isNotEmpty ? '\n${addr.city}' : ''}${addr.state.isNotEmpty ? ', ${addr.state}' : ''}${addr.postalCode.isNotEmpty ? ' ${addr.postalCode}' : ''}'
                          .trim(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF444444),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Contact Details: Phone & Email
                    Row(
                      children: [
                        if (addr.phone.isNotEmpty) ...[
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            addr.phone,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          Text(
                            '  •  ',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            controller.userEmail,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF666666),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
