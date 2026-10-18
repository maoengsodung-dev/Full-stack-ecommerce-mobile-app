import 'package:flutter/material.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';
import '../controllers/checkout_controller.dart';

class PromoCodeSection extends StatelessWidget {
  const PromoCodeSection({
    super.key,
    required this.controller,
  });

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promo code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFEFEF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.promoCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add a code',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.applyPromo,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('APPLY'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
