import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/data/models/notification_model.dart';

import '../providers/notification_provider.dart';

class NotificationItemTile extends ConsumerWidget {
  final NotificationModel item;

  const NotificationItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationNotifierProvider.notifier);
    final timeStr = DateFormat('MMM dd, hh:mm a').format(item.time);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.deleteNotification(item.id);
      },
      child: GestureDetector(
        onTap: () {
          notifier.markAsRead(item.id);
          final slug = item.productSlug;
          final productId = item.productId;
          if (slug != null && slug.isNotEmpty) {
            Navigator.of(context).pushNamed(
              RouteNames.productDetail,
              arguments: slug,
            );
          } else if (productId != null && productId.isNotEmpty) {
            final idInt = int.tryParse(productId);
            Navigator.of(context).pushNamed(
              RouteNames.productDetail,
              arguments: idInt ?? productId,
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFECECF0)
                  : AppColors.primary.withValues(alpha: 0.25),
              width: item.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? const Color(0xFFF1F5F9)
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getIconForType(item.type),
                    size: 20,
                    color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppFonts.font(
                              fontSize: 14,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppFonts.font(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeStr,
                      style: AppFonts.font(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.discount_outlined;
      case 'product':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
