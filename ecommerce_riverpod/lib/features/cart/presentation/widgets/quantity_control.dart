import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/data/models/cart.model.dart';
import '../providers/cart_provider.dart';

class QuantityControl extends ConsumerWidget {
  const QuantityControl({
    super.key,
    required this.item,
  });

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              ref
                  .read(cartNotifierProvider.notifier)
                  .updateQuantity(item.id, item.quantity - 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.quantity.toString(),
              style: AppFonts.font(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          _qtyBtn(
            icon: Icons.add_rounded,
            onTap: () {
              ref
                  .read(cartNotifierProvider.notifier)
                  .updateQuantity(item.id, item.quantity + 1);
            },
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
