import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDCE6FC),
              Color(0xFFEDF2FD),
              Color(0xFFF7F9FE),
            ],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 26,
                              color: Color(0xFF1E1E2D),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.notifications,
                          style: AppFonts.font(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E2D),
                          ),
                        ),
                        Obx(() {
                          final count = controller.unreadCount;
                          if (count <= 0) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B67CA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Obx(() {
                        if (controller.unreadCount <= 0) {
                          return const SizedBox.shrink();
                        }
                        return TextButton(
                          onPressed: controller.markAllAsRead,
                          child: Text(
                            'Mark all read',
                            style: AppFonts.font(
                              color: const Color(0xFF5B67CA),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ─── Notifications List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchNotifications,
                  color: const Color(0xFF5B67CA),
                  child: Obx(() {
                    if (controller.isLoading.value && controller.notifications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF5B67CA)),
                      );
                    }
                    if (controller.notifications.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(),
                          ),
                        ],
                      );
                    }

                    final groups = _groupNotifications(controller.notifications);

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Section Header (Today, Yesterday)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                              child: Text(
                                group.label,
                                style: AppFonts.font(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B1B2F),
                                ),
                              ),
                            ),

                            // Group Card
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Column(
                                  children: [
                                    for (int i = 0; i < group.items.length; i++) ...[
                                      Dismissible(
                                        key: Key('notif_${group.items[i].id}'),
                                        direction: DismissDirection.horizontal,
                                        background: _buildDismissBackground(
                                          isLeft: true,
                                          context: context,
                                        ),
                                        secondaryBackground:
                                            _buildDismissBackground(
                                          isLeft: false,
                                          context: context,
                                        ),
                                        onDismissed: (direction) {
                                          final removedItem = group.items[i];
                                          controller.deleteNotification(
                                              removedItem.id);
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                removedItem.title.isNotEmpty
                                                    ? removedItem.title
                                                    : context
                                                        .l10n.notifications,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppFonts.font(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              backgroundColor:
                                                  const Color(0xFF1E1E2D),
                                              duration:
                                                  const Duration(seconds: 3),
                                              action: SnackBarAction(
                                                label: context.l10n.undo,
                                                textColor:
                                                    const Color(0xFF818CF8),
                                                onPressed: () {
                                                  controller.addNotification(
                                                      removedItem);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildNotificationItem(
                                                group.items[i]),
                                            if (i != group.items.length - 1)
                                              Container(
                                                color: group.items[i].isRead
                                                    ? Colors.white
                                                    : const Color(0xFFF6F8FF),
                                                child: const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xFFF1F3F7),
                                                  indent: 16,
                                                  endIndent: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFF6F8FF),
      child: InkWell(
        onTap: () => controller.onNotificationTapped(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Image Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBgColor(item.type),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, _) => Center(
                            child: Icon(
                              _getIconData(item.type),
                              color: _getIconColor(item.type),
                              size: 24,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          _getIconData(item.type),
                          color: _getIconColor(item.type),
                          size: 24,
                        ),
                      ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppFonts.font(
                              fontSize: 15,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: const Color(0xFF1E1E2D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(item.time),
                          style: AppFonts.font(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E92A4),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5B67CA),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description body
                    Text(
                      item.body,
                      style: AppFonts.font(
                        fontSize: 12.5,
                        color: const Color(0xFF717588),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDismissBackground({
    required bool isLeft,
    required BuildContext context,
  }) {
    return Container(
      color: const Color(0xFFEF4444),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.delete,
              style: AppFonts.font(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ] else ...[
            Text(
              context.l10n.delete,
              style: AppFonts.font(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBgColor(String type) {
    switch (type) {
      case 'product':
        return const Color(0xFFE8F5E9);
      case 'promo':
        return const Color(0xFFFFF3E0);
      case 'order':
        return const Color(0xFFE0F7FA);
      default:
        return const Color(0xFFEEF4FF);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'product':
        return const Color(0xFF2E7D32);
      case 'promo':
        return const Color(0xFFEF6C00);
      case 'order':
        return const Color(0xFF00838F);
      default:
        return const Color(0xFF5B67CA);
    }
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'product':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'order':
        return Icons.receipt_long_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'bell':
      case 'notification':
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 0 ? 1 : diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} h ago';
    }
    return '${diff.inDays} d ago';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 42,
              color: Color(0xFF8E92A4),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            appL10n.noNotifications,
            style: AppFonts.font(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            appL10n.noNotificationsSubtitle,
            textAlign: TextAlign.center,
            style: AppFonts.font(
              fontSize: 13,
              color: const Color(0xFF717588),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<_NotifGroup> _groupNotifications(List<NotificationItem> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <NotificationItem>[];
    final yesterdayItems = <NotificationItem>[];
    final earlierItems = <NotificationItem>[];

    for (final n in notifications) {
      final d = DateTime(n.time.year, n.time.month, n.time.day);
      if (d == today) {
        todayItems.add(n);
      } else if (d == yesterday) {
        yesterdayItems.add(n);
      } else {
        earlierItems.add(n);
      }
    }

    final groups = <_NotifGroup>[];
    if (todayItems.isNotEmpty) groups.add(_NotifGroup('Today', todayItems));
    if (yesterdayItems.isNotEmpty) {
      groups.add(_NotifGroup('Yesterday', yesterdayItems));
    }
    if (earlierItems.isNotEmpty) {
      groups.add(_NotifGroup('Earlier', earlierItems));
    }
    return groups;
  }
}

class _NotifGroup {
  final String label;
  final List<NotificationItem> items;
  _NotifGroup(this.label, this.items);
}
