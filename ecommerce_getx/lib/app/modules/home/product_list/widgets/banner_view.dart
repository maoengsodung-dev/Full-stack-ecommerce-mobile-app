import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/banner.model.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class BannerView extends StatelessWidget {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoadingBanners.value && controller.banners.isEmpty) {
          return _buildLoadingPlaceholder();
        }

        final banners = controller.banners;

        // If no banners returned from server, fallback to default local slides
        if (banners.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Center(child: Text('Banner empty')),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 18),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 150,
              viewportFraction: 0.88,
              enlargeCenterPage: true,
              autoPlay: banners.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 650),
              enableInfiniteScroll: banners.length > 1,
              scrollDirection: Axis.horizontal,
            ),
            items: banners.map((banner) {
              return _buildBannerCard(context, banner, controller);
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildBannerCard(
    BuildContext context,
    BannerModel banner,
    HomeController controller,
  ) {
    final imageUrl = banner.resolvedImageUrl;
    final hasTitle = banner.title != null && banner.title!.trim().isNotEmpty;
    final hasSubtitle =
        banner.subtitle != null && banner.subtitle!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => _handleBannerTap(context, banner, controller),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner Image
              imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF5B4DFF),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 36,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),

              // Gradient Overlay (if banner has title or subtitle)
              if (hasTitle || hasSubtitle)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),

              // Title and Subtitle Text Overlay
              if (hasTitle || hasSubtitle)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasTitle)
                        Text(
                          banner.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      if (hasSubtitle) ...[
                        const SizedBox(height: 2),
                        Text(
                          banner.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Interactive Action Hint Indicator (top right)
              if (banner.linkType != 'none')
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          banner.linkType == 'external'
                              ? Icons.open_in_new_rounded
                              : Icons.arrow_forward_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          banner.linkType == 'product'
                              ? 'View'
                              : (banner.linkType == 'category'
                                    ? 'Category'
                                    : 'Explore'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBannerTap(
    BuildContext context,
    BannerModel banner,
    HomeController controller,
  ) async {
    switch (banner.linkType.toLowerCase()) {
      case 'product':
        if (banner.linkId != null && banner.linkId!.trim().isNotEmpty) {
          final idOrSlug =
              int.tryParse(banner.linkId!.trim()) ?? banner.linkId!.trim();
          Get.toNamed(Routes.PRODUCT_DETAIL, arguments: idOrSlug);
        }
        break;

      case 'category':
        if (banner.linkId != null && banner.linkId!.trim().isNotEmpty) {
          final catId = int.tryParse(banner.linkId!.trim());
          if (catId != null) {
            controller.setCategory(catId);
          }
        }
        break;

      case 'external':
        if (banner.linkUrl != null && banner.linkUrl!.trim().isNotEmpty) {
          final uri = Uri.tryParse(banner.linkUrl!.trim());
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;

      case 'none':
      default:
        break;
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 18, left: 16, right: 16),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF5B4DFF),
            ),
          ),
        ),
      ),
    );
  }
}
