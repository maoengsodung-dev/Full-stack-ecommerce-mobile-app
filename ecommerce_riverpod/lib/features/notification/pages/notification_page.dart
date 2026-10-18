import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/empty_state_widget.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_item_tile.dart';
import '../widgets/notification_shimmer.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);
    final items = state.items;
    final unreadCount = state.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FE),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.notifications,
              style: AppFonts.font(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'read_all') {
                notifier.markAllAsRead();
              } else if (value == 'clear_all') {
                notifier.clearAll();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text('Mark all as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(context.l10n.clearAll),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: state.notifications.when(
        loading: () => const NotificationShimmer(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(error.toString(), style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.fetchNotifications(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(context.l10n.retry, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (_) {
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => notifier.fetchNotifications(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: EmptyStateWidget(
                    assetName: AssetConstants.notification,
                    title: context.l10n.noNotifications,
                    subtitle: context.l10n.noNotificationsSubtitle,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notifier.fetchNotifications(),
            color: AppColors.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return NotificationItemTile(item: items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
