import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/empty_state_widget.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../../main_page/providers/main_page_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersNotifierProvider);
    final notifier = ref.read(ordersNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          context.l10n.myOrders,
          style: AppFonts.font(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Pill Tabs
            Container(
              height: 48,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabPill(
                      title: 'Active',
                      isSelected: state.selectedTab == 0,
                      badgeCount: state.activeCount,
                      onTap: () => notifier.setTab(0),
                    ),
                  ),
                  Expanded(
                    child: _buildTabPill(
                      title: 'Delivered',
                      isSelected: state.selectedTab == 1,
                      badgeCount: state.deliveredCount,
                      onTap: () => notifier.setTab(1),
                    ),
                  ),
                  Expanded(
                    child: _buildTabPill(
                      title: 'Archive',
                      isSelected: state.selectedTab == 2,
                      badgeCount: state.archiveCount,
                      onTap: () => notifier.setTab(2),
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: state.orders.when(
                loading: () => const ShimmerList(count: 3),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: AppFonts.font(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => notifier.fetchOrders(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text(
                              context.l10n.retry,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (_) {
                  final filtered = state.filteredOrders;
                  return RefreshIndicator(
                    onRefresh: () => notifier.fetchOrders(),
                    color: AppColors.primary,
                    child: filtered.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) => SingleChildScrollView(
                              key: ValueKey('orders_empty_${state.selectedTab}'),
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: EmptyStateWidget(
                                    assetName: AssetConstants.order,
                                    title: context.l10n.noOrdersFound,
                                    subtitle: state.selectedTab == 0
                                        ? 'You have no active orders in transit.'
                                        : state.selectedTab == 1
                                        ? 'You have no delivered orders yet.'
                                        : 'No archived orders found.',
                                    actionLabel: context.l10n.shopNow,
                                    onAction: () {
                                      ref
                                          .read(mainPageNotifierProvider.notifier)
                                          .setIndex(0);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            key: ValueKey('orders_list_${state.selectedTab}'),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final order = filtered[index];
                              return OrderCard(
                                key: ValueKey('order_${order.orderNumber}_${order.id}_$index'),
                                order: order,
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

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppFonts.font(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
