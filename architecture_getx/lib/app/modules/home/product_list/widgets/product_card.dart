import 'package:architecture_getx/app/core/theme/app_fonts.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductRes product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product),
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
            // Image
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
                              placeholder: (_, a) {
                                return Container(
                                  color: AppColors.background,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorWidget: (_, a, b) {
                                return Container(
                                  color: AppColors.background,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 36,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                );
                              },
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

                  if (product.stock == 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            context.l10n.outOfStock,
                            style: AppFonts.font(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Information
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null)
                      Text(
                        product.category!.name,
                        style: AppFonts.font(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),

                    const SizedBox(height: 2),

                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.font(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppFonts.font(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          ' (${product.reviewsCount})',
                          style: AppFonts.font(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                          const SizedBox(width: 5),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: AppFonts.font(
                              fontSize: 11,
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
            ),
          ],
        ),
      ),
    );
  }
}
