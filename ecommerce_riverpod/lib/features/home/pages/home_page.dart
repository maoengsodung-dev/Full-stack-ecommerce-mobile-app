import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/core/constants/icons.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_view.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/product_category.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user.valueOrNull;
    final String userName = (user?.name != null && user!.name!.isNotEmpty)
        ? user.name!
        : (user?.email != null && user!.email!.isNotEmpty
            ? user.email!.split('@').first
            : 'Guest User');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.welcome,
              style: AppFonts.font(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              userName,
              style: AppFonts.font(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.notification);
                },
                icon: SvgPicture.asset(
                  kNotification,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeNotifierProvider.notifier).refreshHome(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar & Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        onTap: (){
                          Navigator.of(context).pushNamed(RouteNames.searchProduct);
                        },
                        decoration: InputDecoration(
                          hintText: context.l10n.whatsOnYourList,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              kSearch,
                              colorFilter: const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),

                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),

                      ),
                    ),
                    const SizedBox(width: 12),
                    // Circular Filter Button
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const FilterBottomSheet(),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Slider Banner
            const BannerView(),

            // Categories
            const SliverToBoxAdapter(
              child: ProductCategory(),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.products,
                      style: AppFonts.font(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (homeState.selectedCategory != null)
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(homeNotifierProvider.notifier)
                              .selectCategory(null);
                        },
                        child: Text(
                          'Clear Filter',
                          style: AppFonts.font(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Dynamic Products State
            homeState.products.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        SizedBox(height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(homeNotifierProvider.notifier)
                                  .fetchProducts();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
              ),
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        context.l10n.noProductsFound,
                        style: AppFonts.font(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
