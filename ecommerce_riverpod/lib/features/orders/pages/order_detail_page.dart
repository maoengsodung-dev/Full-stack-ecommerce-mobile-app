import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/currency_utils.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/data/models/order.model.dart';

import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_tracking_timeline.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final OrderRes? initialOrder;

  const OrderDetailPage({super.key, this.initialOrder});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  OrderRes? _resolvedOrder;

  @override
  void initState() {
    super.initState();
    _resolvedOrder = widget.initialOrder;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resolvedOrder != null) {
        ref
            .read(ordersNotifierProvider.notifier)
            .fetchOrderDetail(_resolvedOrder!.id);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedOrder == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is OrderRes) {
        _resolvedOrder = args;
        ref.read(ordersNotifierProvider.notifier).fetchOrderDetail(args.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersNotifierProvider);
    final notifier = ref.read(ordersNotifierProvider.notifier);
    final order = state.selectedOrderDetail.valueOrNull ?? _resolvedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    final canCancel = notifier.canCancelOrder(order);
    final createdAt = order.createdAt;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '#${order.orderNumber}',
          style: AppFonts.font(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Timeline Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: AppFonts.font(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              dateFmt.format(createdAt),
                              style: AppFonts.font(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OrderTrackingTimeline(status: order.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shipping Address Card
            if (order.shippingAddress != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shipping Address',
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.shippingAddress!.fullAddress,
                      style: AppFonts.font(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (order.shippingAddress!.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${order.shippingAddress!.phone}',
                        style: AppFonts.font(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ordered Items Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items (${order.items.length})',
                    style: AppFonts.font(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    final product = item.product;
                    final imgUrl = product.primaryImage?.url;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 52,
                              height: 52,
                              color: AppColors.background,
                              child: (imgUrl != null && imgUrl.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: imgUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textHint,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_outlined,
                                      color: AppColors.textHint,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.font(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity}x ${CurrencyUtils.format(item.price)}',
                                  style: AppFonts.font(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyUtils.format(item.subtotal),
                            style: AppFonts.font(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (canCancel)
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _confirmDeleteItem(
                                context,
                                notifier,
                                order.id,
                                item.id,
                                product.name,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: AppFonts.font(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Subtotal', CurrencyUtils.format(order.subtotal)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Shipping Fee', CurrencyUtils.format(order.shippingFee)),
                  if (order.tax > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow('Tax', CurrencyUtils.format(order.tax)),
                  ],
                  if (order.discount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount',
                      '-${CurrencyUtils.format(order.discount)}',
                      color: Colors.green,
                    ),
                  ],
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Total',
                    CurrencyUtils.format(order.total),
                    isBold: true,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Order Button
            if (canCancel)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _confirmCancelOrder(context, notifier, order.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Cancel Order',
                          style: AppFonts.font(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.font(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppFonts.font(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmCancelOrder(
    BuildContext context,
    OrdersNotifier notifier,
    int orderId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await notifier.cancelOrder(orderId);
              if (mounted && ok) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully.')),
                );
              }
            },
            child: const Text('Cancel Order', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(
    BuildContext context,
    OrdersNotifier notifier,
    int orderId,
    int itemId,
    String itemName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Product'),
        content: Text('Remove "$itemName" from this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await notifier.deleteProductFromOrder(orderId, itemId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
