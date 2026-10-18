import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/empty_state_widget.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_card.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          context.l10n.wishlist,
          style: AppFonts.font(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${wishlistState.itemList.length} ${context.l10n.items}',
              style: AppFonts.font(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: wishlistState.items.when(
        loading: () => const LoadingWidget(),
        error: (err, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: AppFonts.font(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(wishlistNotifierProvider.notifier)
                      .fetchWishlist(showLoading: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(context.l10n.tryAgain),
                ),
              ],
            ),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              assetName: AssetConstants.favorite,
              title: context.l10n.yourWishlistIsEmpty,
              subtitle: context.l10n.wishlistEmptySubtitle,
              actionLabel: context.l10n.exploreProducts,
              onAction: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.shell,
                  (route) => false,
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(wishlistNotifierProvider.notifier)
                  .fetchWishlist(showLoading: false);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return WishlistCard(
                  item: item,
                  onRemove: () {
                    ref
                        .read(wishlistNotifierProvider.notifier)
                        .removeItem(item.id);
                  },
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      RouteNames.productDetail,
                      arguments: item.product ??
                          (item.slug.isNotEmpty ? item.slug : item.toProduct()),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
