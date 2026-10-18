import 'package:architecture_getx/app/core/constants/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../data/models/product.model.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class SearchProduct extends GetView<HomeController> {
  const SearchProduct({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          context.l10n.searchProducts,
          style: AppFonts.font(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

      ),
      body: Column(
        children: [
          // Search Input Bar Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xffF0F0F2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                onSubmitted: (value) =>
                    controller.searchProducts(value, addToRecent: true),
                textInputAction: TextInputAction.search,
                autofocus: true,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.whatsOnYourList,
                  hintStyle: const TextStyle(
                    color: Color(0xffA0A0A5),
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      kSearch,
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchText.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: controller.clearSearch,
                    );
                  }),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          // Main Search Body
          Expanded(
            child: Obx(() {
              // 1. Loading State
              if (controller.isSearching.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primaryLight,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Searching products...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 2. Error State
              if (controller.searchErrorMessage.value.isNotEmpty) {
                return ErrorStateWidget(
                  message: controller.searchErrorMessage.value,
                  onRetry: () =>
                      controller.searchProducts(controller.searchText.value),
                );
              }

              // 3. Initial State (No Search query and no Category selected)
              if (controller.searchText.value.trim().isEmpty &&
                  controller.searchSelectedCategory.value == null) {
                return _buildInitialSearchState();
              }

              // 4. Empty Results State
              if (controller.searchResults.isEmpty) {
                final queryText = controller.searchText.value.isNotEmpty
                    ? '"${controller.searchText.value}"'
                    : 'selected category';
                return EmptyStateWidget(
                  assetName: AssetConstants.search,
                  title: context.l10n.noProductsFound,
                  subtitle:
                      'We couldn\'t find any products for $queryText.\nTry changing keywords or category filter.',
                  actionLabel: 'Clear Search',
                  onAction: controller.clearSearch,
                );
              }

              // 5. Results List
              return _buildSearchResultsList();
            }),
          ),
        ],
      ),
    );
  }

  /// Initial suggestion UI when search bar is empty and no category is selected
  Widget _buildInitialSearchState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Recent Searches Section
          Obx(() {
            if (controller.recentSearches.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appL10n.recentSearches,
                          style: AppFonts.font(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: controller.clearRecentSearches,
                      child: Text(
                        appL10n.clearAll,
                        style: AppFonts.font(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: controller.recentSearches.map((search) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.selectRecentSearch(search),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF0F0F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                search,
                                style: AppFonts.font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeRecentSearch(search),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // Categories Header
          Text(
            appL10n.exploreCategories,
            style: AppFonts.font(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Category Chips Wrap from API
          Obx(() {
            if (controller.isLoadingCategories.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            if (controller.categories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Wrap(
              spacing: 8,
              runSpacing: 10,
              children: controller.categories.map((category) {
                final imgUrl = category.displayImage;
                return ActionChip(
                  avatar: (imgUrl != null && imgUrl.isNotEmpty)
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 20,
                              height: 20,
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.category_outlined,
                                size: 12,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.category_rounded,
                            size: 12,
                            color: AppColors.primaryLight,
                          ),
                        ),
                  label: Text(
                    category.name,
                    style: AppFonts.font(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  pressElevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  onPressed: () {
                    controller.searchByCategory(category.id, category.name);
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Search Results List
  Widget _buildSearchResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Count Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Found ${controller.searchResults.length} ${controller.searchResults.length == 1 ? 'result' : 'results'}',
                style: AppFonts.font(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Obx(() {
                final categoryName = controller.categories
                    .firstWhereOrNull(
                      (c) => c.id == controller.searchSelectedCategory.value,
                    )
                    ?.name;

                if (categoryName != null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryName,
                          style: AppFonts.font(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: controller.clearSearch,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.searchText.value.isNotEmpty) {
                  return Text(
                    'for "${controller.searchText.value}"',
                    style: AppFonts.font(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textHint,
                    ),
                  );
                }

                return const SizedBox.shrink();
              }),
            ],
          ),
        ),

        // Result items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = controller.searchResults[index];
              return _buildProductSearchCard(product);
            },
          ),
        ),
      ],
    );
  }

  /// Detailed Search Product Card Item
  Widget _buildProductSearchCard(ProductRes product) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: AppColors.background,
                    child: CachedNetworkImage(
                      imageUrl: product.primaryImage?.url ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        appL10n.sale,
                        style: AppFonts.font(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Stock Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (product.category != null)
                        Text(
                          product.category!.name.toUpperCase(),
                          style: AppFonts.font(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                            letterSpacing: 0.5,
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (product.stock > 0
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.stock > 0
                              ? appL10n.inStockLabel
                              : appL10n.outOfStock,
                          style: AppFonts.font(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: product.stock > 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.font(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Rating & Reviews
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: AppFonts.font(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' (${product.reviewsCount})',
                        style: AppFonts.font(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${product.effectivePrice.toStringAsFixed(2)}',
                        style: AppFonts.font(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.onSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: AppFonts.font(
                            fontSize: 11.5,
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Chevron Icon
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
