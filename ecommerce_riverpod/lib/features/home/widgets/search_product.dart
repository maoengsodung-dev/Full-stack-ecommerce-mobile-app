import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';


import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/constants/icons.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/empty_state_widget.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../providers/home_provider.dart';
import 'product_card.dart';

class SearchProduct extends ConsumerStatefulWidget {
  const SearchProduct({super.key});

  @override
  ConsumerState<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends ConsumerState<SearchProduct> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(homeNotifierProvider).searchQuery;
    _searchCtrl.text = currentQuery;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

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
          onPressed: () => Navigator.of(context).pop(),
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
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 15),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => notifier.setSearchQuery(val),
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
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    notifier.clearSearch();
                  },
                )
                    : null,

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
          if (_searchCtrl.text.isEmpty &&
              homeState.recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppFonts.font(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: notifier.clearRecentSearches,
                    child: Text(
                      'Clear',
                      style: AppFonts.font(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              children: homeState.recentSearches.map((term) {
                return ActionChip(
                  label: Text(term),
                  onPressed: () {
                    _searchCtrl.text = term;
                    notifier.setSearchQuery(term);
                  },
                );
              }).toList(),
            ),
          ],
          Expanded(
            child: homeState.products.when(
              loading: () => const LoadingWidget(),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No products found',
                    subtitle: 'Try a different search term or category.',
                    assetName: AssetConstants.search,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, idx) {
                    return ProductCard(product: products[idx]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
