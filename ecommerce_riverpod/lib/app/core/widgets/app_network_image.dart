import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../utils/media_url_resolver.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = MediaUrlResolver.resolve(imageUrl);

    Widget imageWidget;
    if (resolvedUrl.isEmpty) {
      imageWidget = _buildErrorWidget();
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Shimmer.fromColors(
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
              ),
            ),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFF1F5F9),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
          ),
        );
  }
}
