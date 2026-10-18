import 'package:architecture_getx/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/wishlist.model.dart';

class WishlistCard extends GetView<WishlistController> {
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
  Widget build(BuildContext context) {
    // Format currency e.g. $515,000 or $120.00
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
            color: Colors.black.withOpacity(0.04),
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
                // Product Image
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

                //Product Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product Name
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),

                      // Subtitle / Location / Category
                      if (item.subtitle != null &&
                          item.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF8C8C8C),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Specifications Row: Size & Rating
                      Row(
                        children: [
                          // Size Spec
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.straighten_rounded,
                                  size: 13,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.size,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Rating Spec
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price
                      Text(
                        fmt.format(item.price),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                    ],
                  ),
                ),

                //  Heart Favorite Action
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
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
