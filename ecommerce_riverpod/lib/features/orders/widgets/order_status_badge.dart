import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String? status;

  const OrderStatusBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final raw = (status ?? '').trim();
    final s = raw.toLowerCase();
    Color bgColor;
    Color textColor;
    String label;

    switch (s) {
      case 'delivered':
      case 'completed':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'Delivered';
        break;
      case 'in_transit':
      case 'out_for_delivery':
      case 'shipped':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        label = 'In Transit';
        break;
      case 'processing':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = 'Processing';
        break;
      case 'pending':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7E22CE);
        label = 'Pending';
        break;
      case 'cancelled':
      case 'canceled':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        label = 'Cancelled';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        label = raw.isNotEmpty ? raw.toUpperCase() : 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
