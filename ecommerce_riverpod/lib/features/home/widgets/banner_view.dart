import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/data/models/banner.model.dart';
import '../providers/home_provider.dart';

class BannerView extends ConsumerStatefulWidget {
  const BannerView({super.key});

  @override
  ConsumerState<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends ConsumerState<BannerView> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    return SliverToBoxAdapter(
      child: homeState.banners.when(
        loading: () => _buildLoadingPlaceholder(),
        error: (_, __) => const SizedBox.shrink(),
        data: (banners) {
          if (banners.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('No banners available')),
            );
          }

          final activeIndex = _currentIndex >= banners.length
              ? 0
              : _currentIndex;

          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 150,
                    viewportFraction: 0.88,
                    enlargeCenterPage: true,
                    autoPlay: banners.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 650,
                    ),
                    enableInfiniteScroll: banners.length > 1,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: banners.map((banner) {
                    return _buildBannerCard(context, banner);
                  }).toList(),
                ),
                if (banners.length > 1) ...[
                  const SizedBox(height: 12),
                  AnimatedSmoothIndicator(
                    activeIndex: activeIndex,
                    count: banners.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: AppColors.primary,
                      dotColor: Color(0xFFCBD5E1),
                      expansionFactor: 3.5,
                      spacing: 5,
                    ),
                    onDotClicked: (index) {
                      _carouselController.animateToPage(index);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerModel banner) {
    final imageUrl = banner.resolvedImageUrl;

    return GestureDetector(
      onTap: () => _handleBannerTap(context, banner),
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
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.textHint,
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBannerTap(BuildContext context, BannerModel banner) async {
    final link = banner.link;
    if (link == null || link.trim().isEmpty) return;

    final trimmed = link.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (trimmed.startsWith('/products/')) {
      final slug = trimmed.replaceFirst('/products/', '');
      Navigator.of(
        context,
      ).pushNamed(RouteNames.productDetail, arguments: slug);
    } else if (trimmed.startsWith('/categories/')) {
      final catId = int.tryParse(trimmed.replaceFirst('/categories/', ''));
      if (catId != null) {
        ref.read(homeNotifierProvider.notifier).selectCategory(catId);
      }
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
