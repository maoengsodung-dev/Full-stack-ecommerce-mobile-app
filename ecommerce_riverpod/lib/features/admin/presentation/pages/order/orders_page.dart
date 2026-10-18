import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/order_card.dart';
import 'update_order_status_page.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _statusFilters = const [
    {'key': 'all', 'label': 'All Orders'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'paid', 'label': 'Paid'},
    {'key': 'processing', 'label': 'Processing'},
    {'key': 'shipped', 'label': 'Shipped'},
    {'key': 'delivered', 'label': 'Delivered'},
    {'key': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).fetchOrders(showLoading: false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStatusSelected(String key) {
    setState(() {
      _selectedStatus = key;
    });
    ref.read(adminNotifierProvider.notifier).fetchOrders(
          status: key == 'all' ? null : key,
        );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final ordersAsync = adminState.orders;

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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Filter Chips
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statusFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _statusFilters[index];
                  final isSelected = _selectedStatus == filter['key'];
                  return ChoiceChip(
                    label: Text(
                      filter['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F172A),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                    ),
                    onSelected: (_) => _onStatusSelected(filter['key']!),
                  );
                },
              ),
            ),
            // Orders List
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F172A)),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(adminNotifierProvider.notifier).fetchOrders(
                                status: _selectedStatus == 'all'
                                    ? null
                                    : _selectedStatus,
                              );
                        },
                        style: OutlinedButton.styleFrom(minimumSize: Size.zero),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
                data: (allOrders) {
                  // Filter by search query if any
                  final filteredList = allOrders.where((order) {
                    if (_searchQuery.isEmpty) return true;
                    final orderNum = order.orderNumber.toLowerCase();
                    final userEmail = (order.userEmail ?? '').toLowerCase();
                    final userName = (order.userName ?? '').toLowerCase();
                    final tracking = (order.trackingNumber ?? '').toLowerCase();
                    return orderNum.contains(_searchQuery) ||
                        userEmail.contains(_searchQuery) ||
                        userName.contains(_searchQuery) ||
                        tracking.contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
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
                            child: const Icon(
                              Icons.inbox_outlined,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
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
                    onRefresh: () => ref
                        .read(adminNotifierProvider.notifier)
                        .fetchOrders(
                          status: _selectedStatus == 'all'
                              ? null
                              : _selectedStatus,
                        ),
                    color: const Color(0xFF0F172A),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final AdminOrder order = filteredList[index];
                        return OrderCard(
                          order: order,
                          onUpdateStatus: () async {
                            final res = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateOrderStatusPage(order: order),
                              ),
                            );
                            if (res == true) {
                              ref
                                  .read(adminNotifierProvider.notifier)
                                  .fetchOrders(
                                    status: _selectedStatus == 'all'
                                        ? null
                                        : _selectedStatus,
                                  );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
