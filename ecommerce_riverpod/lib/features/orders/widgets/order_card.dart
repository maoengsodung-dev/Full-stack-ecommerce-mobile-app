import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/currency_utils.dart';
import '../../../app/data/models/order.model.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'order_status_badge.dart';

class OrderCard extends ConsumerWidget {
  final OrderRes order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = order.items.isNotEmpty ? order.items.first : null;
    final product = item?.product;
    final totalCount = order.items.fold<int>(0, (sum, it) => sum + it.quantity);
    final createdAt = order.createdAt;
    final imageUrl = product?.primaryImage?.url;

    return GestureDetector(
      onTap: () {
        ref.read(ordersNotifierProvider.notifier).fetchOrderDetail(order.id);
        Navigator.of(context).pushNamed(
          RouteNames.orderDetail,
          arguments: order,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header: Number & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '#${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(createdAt),
                          style: AppFonts.font(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OrderStatusBadge(status: order.status),
              ],
            ),

            // Product Preview
            if (product != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: AppColors.background,
                      child: (imageUrl != null && imageUrl.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
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
                          product.name.isNotEmpty ? product.name : 'Product',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item?.quantity ?? 1}x ${CurrencyUtils.format(item?.price ?? 0)}'
                          '${order.items.length > 1 ? '  (+${order.items.length - 1} more)' : ''}',
                          style: AppFonts.font(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Footer: Total & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalCount items',
                        style: AppFonts.font(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(order.total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.font(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product != null && product.id > 0) ...[
                      OutlinedButton(
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).addItem(
                                product.id,
                                quantity: 1,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Buy Again',
                          style: AppFonts.font(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(ordersNotifierProvider.notifier)
                            .fetchOrderDetail(order.id);
                        Navigator.of(context).pushNamed(
                          RouteNames.orderDetail,
                          arguments: order,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Details',
                        style: AppFonts.font(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
