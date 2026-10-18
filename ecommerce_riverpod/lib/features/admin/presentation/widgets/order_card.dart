import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/theme/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final AdminOrder order;
  final VoidCallback? onUpdateStatus;

  const OrderCard({
    super.key,
    required this.order,
    this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final statusColor = _resolveStatusColor(order.status);
    final isPaid = order.isPaid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order #, Status Pills
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                // Order number
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_rounded,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Order number
                      Expanded(
                        child: Text(
                          '#${order.orderNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status badges
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Payment Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.paymentStatus.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isPaid
                                ? const Color(0xFF166534)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),

                      // Delivery Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Metadata: Date & Customer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.createdAt != null)
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (order.customerName != null && order.customerName!.isNotEmpty)
                  Text(
                    order.customerName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
              ],
            ),

            if (order.trackingNumber != null &&
                order.trackingNumber!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Items List
            if (order.items.isNotEmpty) ...[
              Column(
                children: order.items.take(3).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        Text(
                          currencyFormatter.format(item.lineTotal),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (order.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${order.items.length - 3} more items...',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],

            // Customer Note
            if (order.note != null && order.note!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: ${order.note}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Total and Update Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(order.total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                if (onUpdateStatus != null)
                  ElevatedButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text(
                      'Update Status',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.neonLime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _resolveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'shipped':
        return const Color(0xFF2563EB);
      case 'processing':
        return const Color(0xFFD97706);
      case 'paid':
        return const Color(0xFF0D9488);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'pending':
      default:
        return const Color(0xFF64748B);
    }
  }
}
