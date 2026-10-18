import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../routes/app_pages.dart';
import '../controllers/wishlist_controller.dart';
import '../widgets/wishlist_card.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
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
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${controller.wishlistItems.length} ${context.l10n.items}',
                style: AppFonts.font(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.wishlistItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: AppFonts.font(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        controller.fetchWishlist(showLoading: true),
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
            ),
          );
        }

        //  Empty State
        if (controller.wishlistItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchWishlist(showLoading: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildEmptyState(context),
              ),
            ),
          );
        }

        //  Populated List
        return RefreshIndicator(
          onRefresh: () => controller.fetchWishlist(showLoading: false),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: controller.wishlistItems.length,
            itemBuilder: (context, index) {
              final item = controller.wishlistItems[index];
              return WishlistCard(
                item: item,
                onRemove: () => controller.removeItem(item.id),
                onTap: () {
                  if (item.product != null) {
                    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: item.product);
                  } else if (item.productId != 0) {
                    Get.toNamed(
                      Routes.PRODUCT_DETAIL,
                      arguments: item.productId,
                    );
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SvgPicture.asset(
                AssetConstants.product,
                width: 50,
                height: 50,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.yourWishlistIsEmpty,
              style: AppFonts.font(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.wishlistEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppFonts.font(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
