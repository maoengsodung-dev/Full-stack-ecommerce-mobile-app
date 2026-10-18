import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/loading_widget.dart';

import '../providers/product_detail_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final dynamic productOrId;

  const ProductDetailPage({super.key, this.productOrId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late final PageController _imagePageController;
  dynamic _resolvedArg;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _resolvedArg = widget.productOrId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedArg == null) {
      _resolvedArg = ModalRoute.of(context)?.settings.arguments;
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider(_resolvedArg));
    final notifier = ref.read(productDetailProvider(_resolvedArg).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 26,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          state.product.when(
            loading: () => '',
            error: (_, __) => '',
            data: (product) => product.name,
          ),
        ),
        actions: [
          GestureDetector(
          onTap: notifier.toggleFavorite,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  state.isFavorite
                      ? AssetConstants.favoriteCheck
                      : AssetConstants.favorite,
                  color: state.isFavorite ? AppColors.error:
                      AppColors.textSecondary
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.product.when(
        loading: () => const LoadingWidget(),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading product: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
        data: (product) {
          final images = state.allImages;
          final colors = state.availableColors;
          final sizes = state.availableSizes;
          final price = state.currentPrice;
          final basePrice = product.price;
          final originalPrice = basePrice > price ? basePrice : price * 1.2;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      SizedBox(
                        height: 340,
                        child: Stack(
                          children: [
                            if (images.isNotEmpty)
                              PageView.builder(
                                controller: _imagePageController,
                                itemCount: images.length,
                                onPageChanged: notifier.setImageIndex,
                                itemBuilder: (context, idx) {
                                  return CachedNetworkImage(
                                    imageUrl: images[idx].url,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      size: 64,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  );
                                },
                              )
                            else
                              const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            if (images.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(images.length, (i) {
                                    final isSelected =
                                        state.currentImageIndex == i;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: isSelected ? 18 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFFCBD5E1),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Details Body
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Category & Rating
                            Row(
                              children: [
                                Text(
                                  product.category?.name ?? 'Collection',
                                  style: AppFonts.font(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 19,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating > 0
                                      ? product.rating.toStringAsFixed(1)
                                      : '0',
                                  style: AppFonts.font(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Name & Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: AppFonts.font(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (originalPrice > price)
                                      Text(
                                        '\$${originalPrice.toStringAsFixed(2)}',
                                        style: AppFonts.font(
                                          fontSize: 13,
                                          color: const Color(0xFF94A3B8),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: AppFonts.font(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Image Thumbnail List
                            if (images.length > 1) ...[
                              Text(
                                'PRODUCT GALLERY',
                                style: AppFonts.font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 64,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, idx) {
                                    final isSelected =
                                        state.currentImageIndex == idx;
                                    return GestureDetector(
                                      onTap: () {
                                        _imagePageController.animateToPage(
                                          idx,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Container(
                                        width: 64,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : const Color(0xFFE2E8F0),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: images[idx].url,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Colors
                            if (colors.isNotEmpty) ...[
                              Text(
                                'COLOR',
                                style: AppFonts.font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: colors.map((c) {
                                  final isSelected = state.selectedColor == c;
                                  return ChoiceChip(
                                    label: Text(c),
                                    selected: isSelected,
                                    onSelected: (_) => notifier.selectColor(c),
                                    selectedColor: AppColors.primary,
                                    labelStyle: AppFonts.font(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Sizes
                            if (sizes.isNotEmpty) ...[
                              Text(
                                'SIZE',
                                style: AppFonts.font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: sizes.map((s) {
                                  final isSelected = state.selectedSize == s;
                                  return ChoiceChip(
                                    label: Text(s),
                                    selected: isSelected,
                                    onSelected: (_) => notifier.selectSize(s),
                                    selectedColor: AppColors.primary,
                                    labelStyle: AppFonts.font(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Description
                            Text(
                              'DESCRIPTION',
                              style: AppFonts.font(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description.isNotEmpty
                                  ? product.description
                                  : 'Exclusive quality garment constructed with utmost attention to finish and styling details.',
                              style: AppFonts.font(
                                fontSize: 13.5,
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Add to Cart
                      Expanded(
                        child: GestureDetector(
                          onTap: state.isAddingToCart
                              ? null
                              : () async {
                                  final success = await notifier.addToCart();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? '${product.name} added to cart'
                                            : 'Failed to add to cart',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                  if (success) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: Text(
                                      context.l10n.addToCart,
                                      style: AppFonts.font(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Buy Now / Go to Cart
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await notifier.addToCart();
                            if (!context.mounted) return;
                            Navigator.of(context).pushNamed(RouteNames.cart);
                          },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 20,
                                  color: AppColors.surface,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Buy Now',
                                  style: AppFonts.font(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.surface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
