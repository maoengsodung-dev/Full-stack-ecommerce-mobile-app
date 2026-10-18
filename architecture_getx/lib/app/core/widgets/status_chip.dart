import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'processing':
        return AppColors.statusProcessing;
      case 'shipped':
        return AppColors.statusShipped;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
      case 'canceled':
        return AppColors.statusCancelled;
      case 'paid':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'processing':
        return Icons.inventory_2_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_rounded;
      case 'paid':
        return Icons.payments_rounded;
      case 'failed':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: AppFonts.font(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
