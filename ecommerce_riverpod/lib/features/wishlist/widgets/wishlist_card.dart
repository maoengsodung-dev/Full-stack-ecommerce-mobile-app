import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/data/models/wishlist.model.dart';
import '../providers/wishlist_provider.dart';

class WishlistCard extends ConsumerWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const WishlistCard({
    super.key,
    required this.item,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: item.price >= 1000 ? 0 : 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 104,
                    height: 104,
                    color: const Color(0xFFF3F3F7),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF3F3F7),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF3F3F7),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.font(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.categoryName,
                        style: AppFonts.font(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            fmt.format(item.price),
                            style: AppFonts.font(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: SvgPicture.asset(
                              AssetConstants.cart,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            tooltip: 'Move to Bag',
                            onPressed: () {
                              ref
                                  .read(wishlistNotifierProvider.notifier)
                                  .moveToCart(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.success,
                                  content: Text('${item.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                                snackBarAnimationStyle: const AnimationStyle(
                                  curve: Curves.easeOutBack,
                                  reverseCurve: Curves.easeIn,
                                  duration: Duration(milliseconds: 400),
                                  reverseDuration: Duration(milliseconds: 250),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              AssetConstants.favoriteCheck,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                AppColors.error,
                                BlendMode.srcIn,
                              ),
                            ),


                            onPressed: onRemove,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
