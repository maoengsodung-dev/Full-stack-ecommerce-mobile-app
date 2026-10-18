import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/data/models/product.model.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductRes product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistNotifierProvider);
    final isFav = wishlist.isItemInWishlist(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(RouteNames.productDetail, arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: (product.primaryImage?.url.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                              imageUrl: product.primaryImage!.url,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.background,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 36,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.background,
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 36,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (product.onSale)
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.l10n.sale,
                          style: AppFonts.font(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(wishlistNotifierProvider.notifier)
                            .toggleWishlist(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          isFav
                              ? AssetConstants.favoriteCheck
                              : AssetConstants.favorite,
                          width: 20,
                          height: 20,
                          color: isFav? AppColors.accent
                              : AppColors.textSecondary,
                        ),

                        // Icon(
                        //   isFav
                        //       ? Icons.favorite
                        //       : Icons.favorite_border_rounded,
                        //   size: 18,
                        //   color: isFav
                        //       ? AppColors.accent
                        //       : AppColors.textSecondary,
                        // ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.font(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        Text(
                          product.rating.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.font(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.effectivePrice > 0 ? product.effectivePrice.toStringAsFixed(2) : product.price.toStringAsFixed(2)}',
                              style: AppFonts.font(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (product.onSale)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppFonts.font(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(cartNotifierProvider.notifier)
                                .addItem(product.id, product: product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            AssetConstants.cart,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
