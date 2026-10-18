import 'package:flutter/material.dart';

class CheckoutRadioIcon extends StatelessWidget {
  const CheckoutRadioIcon({
    super.key,
    required this.isSelected,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF0267F6) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF0267F6) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Center(
              child: Icon(
                Icons.check,
                size: 13,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

