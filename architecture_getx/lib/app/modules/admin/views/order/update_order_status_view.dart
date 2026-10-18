import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/order_model.dart';

class UpdateOrderStatusView extends StatefulWidget {
  const UpdateOrderStatusView({super.key});

  @override
  State<UpdateOrderStatusView> createState() => _UpdateOrderStatusViewState();
}

class _UpdateOrderStatusViewState extends State<UpdateOrderStatusView> {
  late AdminOrder _order;
  late String _selectedStatus;
  late final TextEditingController _trackingCtrl;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending', 'color': Color(0xFF64748B)},
    {'value': 'processing', 'label': 'Processing', 'color': Color(0xFFD97706)},
    {'value': 'shipped', 'label': 'Shipped', 'color': Color(0xFF2563EB)},
    {'value': 'delivered', 'label': 'Delivered', 'color': Color(0xFF16A34A)},
    {'value': 'cancelled', 'label': 'Cancelled', 'color': Color(0xFFDC2626)},
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is AdminOrder) {
      _order = args;
    } else {
      _order = const AdminOrder(
        id: 0,
        orderNumber: '',
        status: 'pending',
        paymentStatus: 'pending',
        subtotal: 0,
        total: 0,
      );
    }

    _selectedStatus = _order.status.toLowerCase();
    _trackingCtrl = TextEditingController(text: _order.trackingNumber ?? '');
  }

  @override
  void dispose() {
    _trackingCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AdminController controller) async {
    final success = await controller.updateOrderStatus(
      _order.id,
      status: _selectedStatus,
      trackingNumber: _trackingCtrl.text.trim().isNotEmpty
          ? _trackingCtrl.text.trim()
          : null,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Update Order #${_order.orderNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${_order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_order.customerName != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _order.customerName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _order.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _order.isPaid
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Selector
              const Text(
                'Select Fulfillment Status *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: _statusOptions.map((opt) {
                  final val = opt['value'] as String;
                  final label = opt['label'] as String;
                  final color = opt['color'] as Color;
                  final isSelected = _selectedStatus == val;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: val,
                      groupValue: _selectedStatus,
                      activeColor: color,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : const Color(0xFF334155),
                        ),
                      ),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() => _selectedStatus = newVal);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Tracking Number
              const Text(
                'Tracking Number (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _trackingCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. TRK-987654321',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() {
                final isBusy = controller.isSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : () => _submit(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text(
                            'Save Status Update',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
