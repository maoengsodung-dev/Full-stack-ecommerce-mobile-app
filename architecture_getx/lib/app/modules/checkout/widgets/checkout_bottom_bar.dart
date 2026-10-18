import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/checkout_controller.dart';

class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.controller,
  });

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPlacing = controller.isPlacingOrder.value;

      return Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 8
              : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4F835),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: isPlacing ? null : controller.onPlaceOrder,
            child: isPlacing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.2,
                    ),
                  )
                : Text(
                    context.l10n.placeOrder,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
