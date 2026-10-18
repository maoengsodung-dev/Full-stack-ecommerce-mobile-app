import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import 'update_order_status_view.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    final statusFilters = [
      {'key': 'all', 'label': 'All Orders'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'processing', 'label': 'Processing'},
      {'key': 'shipped', 'label': 'Shipped'},
      {'key': 'delivered', 'label': 'Delivered'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Chips Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: controller.setOrderSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search order #, customer, tracking...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Status Filter Chips
                  SizedBox(
                    height: 34,
                    child: Obx(() {
                      final currentFilter = controller.orderStatusFilter.value;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: statusFilters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final f = statusFilters[idx];
                          final isSelected = currentFilter.toLowerCase() == f['key']!.toLowerCase();

                          return InkWell(
                            onTap: () => controller.setOrderStatusFilter(f['key']!),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                f['label']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Orders List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingOrders.value && controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
                }

                if (controller.ordersError.value.isNotEmpty && controller.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          controller.ordersError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: controller.loadOrders,
                          style: OutlinedButton.styleFrom(minimumSize: Size.zero),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final list = controller.filteredOrders;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadOrders,
                  color: const Color(0xFF0F172A),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final AdminOrder order = list[index];
                      return OrderCard(
                        order: order,
                        onUpdateStatus: () {
                          Get.to(() => const UpdateOrderStatusView(), arguments: order);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
