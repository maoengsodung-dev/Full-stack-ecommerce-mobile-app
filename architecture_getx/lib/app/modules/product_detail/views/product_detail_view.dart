import 'package:architecture_getx/app/core/theme/app_fonts.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  final ProductRes? pro;

  const ProductDetailView({super.key, this.pro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: _buildCircleButton(
          icon: Icons.chevron_left_rounded,
          iconSize: 26,
          onTap: () => Get.back(),
        ),
        actions: [
          Obx(
            () => _buildCircleButton(
              icon: controller.isFavorite.value
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: controller.isFavorite.value
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF0F172A),
              onTap: controller.toggleFavorite,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Section (Top Bar + Image Carousel) ─────
                  _buildHeroSection(context),

                  // ── Details Body
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Brand / Seller Row with Rating
                        _buildBrandAndRatingRow(),
                        const SizedBox(height: 12),

                        // Product Title & Pricing Row
                        _buildTitleAndPriceRow(),
                        const SizedBox(height: 24),

                        Text(
                          'IMAGE PRODUCT',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // List images
                        ListImageProduct(controller: controller),

                        // LIST COLORS
                        const SizedBox(height: 20),
                        Text(
                          'COLOR',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // List colors from API variants (shown as color swatches)
                        Obx(() {
                          final colors = controller.availableColors;
                          final selected = controller.selectedColor.value;
                          if (colors.isEmpty) return const SizedBox.shrink();
                          return SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: colors.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final colorName = colors[index];
                                final isSelected = selected == colorName;
                                final swatchColor = _parseColorFromString(
                                  colorName,
                                );
                                final isLight =
                                    swatchColor.computeLuminance() > 0.5;
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectColor(colorName),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: swatchColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFFE2E8F0),
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: swatchColor.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_rounded,
                                                size: 18,
                                                color: isLight
                                                    ? const Color(0xFF0F172A)
                                                    : Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        colorName,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 22),

                        // Size Selector & Quantity Stepper
                        _buildSizeAndQuantityRow(),
                        const SizedBox(height: 28),

                        // Product Descriptions Accordion
                        _buildProductDescriptionAccordion(),
                        const SizedBox(height: 24),

                        // Reviews Section
                        _buildReviewsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Action Bar (Add to cart / Pay Now) ─
          _buildBottomBar(),
        ],
      ),
    );
  }


  // Hero Section with Floating Top Bar, 360° pill, -20% badge & Dots
  Widget _buildHeroSection(BuildContext context) {
    return Obx(() {
      final current = controller.product.value ?? pro;
      if (current == null) return const SizedBox.shrink();
      final images = controller.allImages;
      final currentIdx = controller.currentImageIndex.value;
      final fallbackUrl = current.primaryImage?.url ?? '';

      // Calculate discount badge percentage
      final basePrice = current.price;
      final currentPrice = controller.currentPrice;
      int discountPercent = 20;
      if (basePrice > currentPrice && basePrice > 0) {
        discountPercent = (((basePrice - currentPrice) / basePrice) * 100)
            .round();
      }

      return Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F7),
        child: Column(
          children: [
            // Carousel Image with 360° pill
            SizedBox(
              height: 290,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      controller: controller.imagePageController,
                      itemCount: images.length,
                      onPageChanged: (idx) =>
                          controller.currentImageIndex.value = idx,
                      itemBuilder: (context, index) {
                        return Center(
                          child: CachedNetworkImage(
                            height: double.infinity,
                            width: double.infinity,
                            imageUrl: images[index].url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: fallbackUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: fallbackUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Color(0xFFCBD5E1),
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                    ),

                  // Floating
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: controller.previousImage,
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 50),

                              GestureDetector(
                                onTap: controller.nextImage,
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Centered Pagination Dots
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                images.length > 1 ? images.length : 4,
                                (i) {
                                  final isSelected = currentIdx == i;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // // Discount Badge
                  // if (discountPercent > 0)
                  //   Positioned(
                  //     top: 10,
                  //     right: 2,
                  //     child:  Row(
                  //       children: [
                  //         // Discount badge pill
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(
                  //             horizontal: 14,
                  //             vertical: 6,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: const Color(0xFFE52E2E),
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //           child: Text(
                  //             '-$discountPercent%',
                  //             style: GoogleFonts.poppins(
                  //               fontSize: 13,
                  //               fontWeight: FontWeight.w700,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //
                  //
                  //
                  //       ],
                  //     ),
                  //   )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCircleButton({
    required IconData icon,
    double iconSize = 22,
    Color iconColor = const Color(0xFF0F172A),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
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
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Brand / Seller Row with Verified Check & Rating
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBrandAndRatingRow() {
    return Obx(() {
      final current = controller.product.value ?? pro;
      if (current == null) return const SizedBox.shrink();
      final brandName = current.category?.name ?? 'WinterElegance';
      final rating = current.rating > 0
          ? current.rating.toStringAsFixed(1)
          : '4.7';

      return Row(
        children: [
          // Circular Brand Avatar
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                brandName.isNotEmpty ? brandName[0].toUpperCase() : '9',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Brand Name
          Text(
            brandName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 5),

          // Verified Icon
          const Icon(Icons.verified, size: 16, color: Color(0xFF2563EB)),

          const Spacer(),

          // Star Rating
          const Icon(Icons.star_rounded, size: 19, color: Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text(
            rating,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Product Title & Pricing Row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTitleAndPriceRow() {
    return Obx(() {
      final current = controller.product.value ?? pro;
      if (current == null) return const SizedBox.shrink();
      final price = controller.currentPrice;
      final basePrice = current.price;
      final originalPrice = basePrice > price ? basePrice : price * 1.2;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name on the left
          Expanded(
            child: Text(
              current.name.isNotEmpty
                  ? current.name
                  : 'Light Hooded\nTracksuit',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 14),

          // Pricing on the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Color Parsing Helper
  // ─────────────────────────────────────────────────────────────────────────

  /// Parses a color string from the API.
  /// Supports hex strings (#RRGGBB, #RGB) and common CSS color names.
  Color _parseColorFromString(String colorStr) {
    final s = colorStr.trim().toLowerCase();

    // --- Hex format ---
    if (s.startsWith('#')) {
      final hex = s.replaceFirst('#', '');
      if (hex.length == 3) {
        final r = hex[0] * 2;
        final g = hex[1] * 2;
        final b = hex[2] * 2;
        final value = int.tryParse('FF$r$g$b', radix: 16);
        if (value != null) return Color(value);
      } else if (hex.length == 6) {
        final value = int.tryParse('FF$hex', radix: 16);
        if (value != null) return Color(value);
      }
    }

    // --- Named colors dictionary ---
    const namedColors = <String, Color>{
      'red': Color(0xFFEF4444),
      'blue': Color(0xFF3B82F6),
      'green': Color(0xFF22C55E),
      'yellow': Color(0xFFFACC15),
      'orange': Color(0xFFF97316),
      'purple': Color(0xFFA855F7),
      'pink': Color(0xFFEC4899),
      'black': Color(0xFF1C1C1C),
      'white': Color(0xFFF8F8F8),
      'grey': Color(0xFF9CA3AF),
      'gray': Color(0xFF9CA3AF),
      'brown': Color(0xFF92400E),
      'navy': Color(0xFF1E3A5F),
      'teal': Color(0xFF14B8A6),
      'cyan': Color(0xFF06B6D4),
      'indigo': Color(0xFF6366F1),
      'violet': Color(0xFF7C3AED),
      'beige': Color(0xFFF5F0E8),
      'cream': Color(0xFFFFF8E7),
      'gold': Color(0xFFD4AF37),
      'silver': Color(0xFFC0C0C0),
      'maroon': Color(0xFF800000),
      'olive': Color(0xFF6B7280),
      'coral': Color(0xFFFF6B6B),
      'salmon': Color(0xFFFA8072),
      'khaki': Color(0xFFC3B091),
      'lavender': Color(0xFFE6E6FA),
      'mint': Color(0xFF98FF98),
      'rose': Color(0xFFFFE4E6),
      'charcoal': Color(0xFF36454F),
      'slate': Color(0xFF64748B),
      'oatmeal': Color(0xFFEBE7DD),
      'ecru': Color(0xFFFAF7EE),
      'onyx': Color(0xFF18181B),
      'ivory': Color(0xFFFFFFF0),
      'tan': Color(0xFFD2B48C),
      'taupe': Color(0xFF483C32),
      'rust': Color(0xFFB7410E),
      'burgundy': Color(0xFF800020),
      'magenta': Color(0xFFFF00FF),
      'lime': Color(0xFF84CC16),
      'turquoise': Color(0xFF40E0D0),
    };

    return namedColors[s] ?? const Color(0xFFD1D5DB);
  }

  Widget _colorTextOrPlaceholder(_ColorCardItem item) {
    return Center(
      child: Text(
        item.label,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: item.isDark ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Size Selector & Quantity Stepper in the same row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSizeAndQuantityRow() {
    return Obx(() {
      final sizes = controller.availableSizes;
      final selectedSize = controller.selectedSize.value.isNotEmpty
          ? controller.selectedSize.value
          : (sizes.contains('M') ? 'M' : sizes.firstOrNull ?? 'M');

      return Row(
        children: [
          // Left: Size Capsule Segment
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: sizes.map((size) {
                final isSelected = selectedSize == size;
                return GestureDetector(
                  onTap: () => controller.selectSize(size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF155DFC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF155DFC,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Spacer(),

          // Right: Quantity Stepper Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrement button
                GestureDetector(
                  onTap: controller.decrement,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${controller.quantity.value}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                // Increment button
                GestureDetector(
                  onTap: controller.increment,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Product Descriptions Accordion
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProductDescriptionAccordion() {
    return Obx(() {
      final current = controller.product.value ?? pro;
      if (current == null) return const SizedBox.shrink();
      final isExpanded = controller.isDescriptionExpanded.value;
      final descText = current.description.isNotEmpty
          ? current.description
          : 'Heavyweight organic cotton loopback fleece crafted with a relaxed tailored drape.';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accordion Header
          GestureDetector(
            onTap: controller.isDescriptionExpanded.toggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appL10n.description,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: const Color(0xFF0F172A),
                ),
              ],
            ),
          ),

          // Content Box
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                descText,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reviews Section with Carousel Cards
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReviewsSection() {
    return Obx(() {
      final current = controller.product.value ?? pro;
      if (current == null) return const SizedBox.shrink();
      final reviewsCount = current.reviewsCount > 0 ? current.reviewsCount : 48;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appL10n.customerReviews,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Reviews',
                    'Displaying all $reviewsCount reviews',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1),
                  );
                },
                child: Text(
                  '${appL10n.viewAll} ($reviewsCount)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF155DFC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Reviews List
          SizedBox(
            height: 175,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildReviewCard(
                  avatarInitials: 'ER',
                  name: 'Elena R.',
                  timeAgo: '2 days ago',
                  title: 'Exceptional drape & texture',
                  content:
                      'The heavyweight French terry feels incredibly premium. Sizing is spot on relaxed fit.',
                ),
                const SizedBox(width: 12),
                _buildReviewCard(
                  avatarInitials: 'JK',
                  name: 'Julian K.',
                  timeAgo: '1 week ago',
                  title: 'Worth every penny',
                  content:
                      'The pale ecru color is stunning in person. Atelier craftsmanship and stitch quality are second to none.',
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReviewCard({
    required String avatarInitials,
    required String name,
    required String timeAgo,
    required String title,
    required String content,
  }) {
    return Container(
      width: 275,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Top Row
          Row(
            children: [
              // Avatar
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatarInitials,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Name + Verified Badge + Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                  Text(
                    timeAgo,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Rating Stars
              Row(
                children: List.generate(
                  5,
                  (_) => const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Content
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Verified Buyer tag
          Text(
            'Verified Buyer',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bottom Action Bar: Add to cart (Black) + Pay Now (Neon Lime)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
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
      child: Obx(() {
        final isAdding = controller.isAddingToCart.value;

        return Row(
          children: [
            // Add to Cart Button (Deep Black)
            Expanded(
              child: GestureDetector(
                onTap: isAdding ? null : controller.addToCart,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            appL10n.addToCart,
                            style: GoogleFonts.poppins(
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

            // Pay Now Button (Bright Lime Neon Green)
            Expanded(
              child: GestureDetector(
                onTap: isAdding ? null : controller.buyNow,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F000), // Vibrant neon lime
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appL10n.payNow,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class ListImageProduct extends StatelessWidget {
  const ListImageProduct({super.key, required this.controller});

  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.allImages;
      // Read currentImageIndex here so Obx tracks it as a dependency —
      // rebuilds the list whenever the selection changes.
      final currentIdx = controller.currentImageIndex.value;

      return SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final isSelected = currentIdx == index;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => controller.selectImage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF0F172A).withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isSelected ? 8 : 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      images[index].url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ColorCardItem {
  final String label;
  final String? imageUrl;
  final Color color;
  final bool isDark;

  _ColorCardItem({
    required this.label,
    this.imageUrl,
    required this.color,
    this.isDark = false,
  });
}
