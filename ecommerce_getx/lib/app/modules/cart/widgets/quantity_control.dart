import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:architecture_getx/app/data/models/cart.model.dart';
import '../controllers/cart_controller.dart';

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.item,
    required this.controller,
  });

  final CartItem item;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement circular button
          _qtyBtn(
            icon: Icons.remove_rounded,
            onTap: () => controller.decreaseQuantity(item.id, item.quantity),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.quantity.toString(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          // Increment circular button
          _qtyBtn(
            icon: Icons.add_rounded,
            onTap: () => controller.increaseQuantity(item.id, item.quantity),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: const Color(0xFF0F172A)),
      ),
    );
  }
}
