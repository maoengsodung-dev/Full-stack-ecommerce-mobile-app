import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../providers/admin_provider.dart';

class UpdateOrderStatusPage extends ConsumerStatefulWidget {
  final AdminOrder order;

  const UpdateOrderStatusPage({super.key, required this.order});

  @override
  ConsumerState<UpdateOrderStatusPage> createState() =>
      _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends ConsumerState<UpdateOrderStatusPage> {
  late String _selectedStatus;
  late final TextEditingController _trackingCtrl;

  static const List<Map<String, dynamic>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending', 'color': Color(0xFF64748B)},
    {'value': 'paid', 'label': 'Paid', 'color': Color(0xFF0D9488)},
    {'value': 'processing', 'label': 'Processing', 'color': Color(0xFFD97706)},
    {'value': 'shipped', 'label': 'Shipped', 'color': Color(0xFF2563EB)},
    {'value': 'delivered', 'label': 'Delivered', 'color': Color(0xFF16A34A)},
    {'value': 'cancelled', 'label': 'Cancelled', 'color': Color(0xFFDC2626)},
  ];

  /// Backend state machine allowed forward transitions:
  /// pending -> processing, paid, cancelled
  /// paid -> processing, cancelled
  /// processing -> shipped, cancelled
  /// shipped -> delivered, cancelled
  /// delivered -> (none, terminal)
  /// cancelled -> (none, terminal)
  static const Map<String, List<String>> _allowedTransitions = {
    'pending': ['paid', 'processing', 'cancelled'],
    'paid': ['processing', 'cancelled'],
    'processing': ['shipped', 'cancelled'],
    'shipped': ['delivered', 'cancelled'],
    'delivered': [],
    'cancelled': [],
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status.toLowerCase();
    _trackingCtrl = TextEditingController(text: widget.order.trackingNumber ?? '');
  }

  @override
  void dispose() {
    _trackingCtrl.dispose();
    super.dispose();
  }

  bool _isTransitionAllowed(String target) {
    final current = widget.order.status.toLowerCase();
    if (target == current) return true;
    final allowed = _allowedTransitions[current] ?? [];
    return allowed.contains(target);
  }

  String? _getDisabledReason(String current, String target) {
    if (current == target) return null;
    if (current == 'delivered') return 'Order is already delivered (final state)';
    if (current == 'cancelled') return 'Order is cancelled (final state)';
    if (current == 'pending') {
      if (target == 'shipped') return 'Must be set to Processing first';
      if (target == 'delivered') return 'Must transition to Processing, then Shipped first';
    }
    if (current == 'paid') {
      if (target == 'pending') return 'Cannot revert to Pending';
      if (target == 'shipped') return 'Must be set to Processing first';
      if (target == 'delivered') return 'Must transition to Processing, then Shipped first';
    }
    if (current == 'processing') {
      if (target == 'pending' || target == 'paid') return 'Cannot revert to earlier stage';
      if (target == 'delivered') return 'Must be set to Shipped first';
    }
    if (current == 'shipped') {
      if (target == 'pending' || target == 'paid' || target == 'processing') {
        return 'Cannot revert shipped order';
      }
    }
    return 'Invalid status transition';
  }

  Future<void> _submit() async {
    final current = widget.order.status.toLowerCase();
    if (_selectedStatus == current &&
        _trackingCtrl.text.trim() == (widget.order.trackingNumber ?? '').trim()) {
      Navigator.of(context).pop();
      return;
    }

    final success =
        await ref.read(adminNotifierProvider.notifier).updateOrderStatus(
              widget.order.id,
              status: _selectedStatus,
              trackingNumber: _trackingCtrl.text.trim().isNotEmpty
                  ? _trackingCtrl.text.trim()
                  : null,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final err = ref.read(adminNotifierProvider).actionState.error?.toString() ??
          'Failed to update order status';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final isSubmitting = adminState.actionState.isLoading;
    final currentStatus = widget.order.status.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.orderNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workflow Information Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 18, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text(
                        'Fulfillment Lifecycle',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Orders progress sequentially:\nPending ➔ (Paid) ➔ Processing ➔ Shipped ➔ Delivered',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Current Status: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(currentStatus).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(currentStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Selection Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Fulfillment Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._statusOptions.map((opt) {
                    final val = opt['value'] as String;
                    final isSelected = _selectedStatus == val;
                    final color = opt['color'] as Color;
                    final isAllowed = _isTransitionAllowed(val);
                    final isCurrent = val == currentStatus;
                    final disabledReason = _getDisabledReason(currentStatus, val);

                    return Opacity(
                      opacity: isAllowed ? 1.0 : 0.45,
                      child: RadioListTile<String>(
                        value: val,
                        groupValue: _selectedStatus,
                        title: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? color
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CURRENT',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: disabledReason != null && !isAllowed
                            ? Text(
                                disabledReason,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              )
                            : null,
                        onChanged: isAllowed
                            ? (v) {
                                if (v != null) {
                                  setState(() => _selectedStatus = v);
                                }
                              }
                            : null,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _trackingCtrl,
              decoration: InputDecoration(
                labelText: 'Tracking Number (optional)',
                hintText: _selectedStatus == 'shipped'
                    ? 'e.g. TRK-98234190'
                    : 'Add tracking number when shipped',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Order Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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
