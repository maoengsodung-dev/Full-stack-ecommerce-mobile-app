import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/banner_model.dart';

class BannerCard extends StatelessWidget {
  final AdminBanner banner;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleActive;

  const BannerCard({
    super.key,
    required this.banner,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.resolvedImageUrl;
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap ?? onEdit,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Header
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF5B4DFF),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),
                  ),

                  // Position badge (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.view_carousel_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            banner.position,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Active / Inactive Badge (top-right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        banner.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Banner Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      banner.title?.isNotEmpty == true
                          ? banner.title!
                          : '(No title)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                      Text(
                        banner.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Info chips row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Link type chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                banner.linkType == 'none'
                                    ? Icons.link_off_rounded
                                    : Icons.link_rounded,
                                size: 13,
                                color: const Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLinkDescription(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sort order chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sort_rounded,
                                size: 13,
                                color: Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Order: ${banner.sortOrder}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),

                    // Actions Row
                    Row(
                      children: [
                        // Active switch toggle
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 38,
                              child: Switch(
                                value: banner.isActive,
                                onChanged: onToggleActive,
                                activeThumbColor: const Color(0xFF10B981),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              banner.isActive ? 'Active' : 'Disabled',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: banner.isActive
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Edit Button
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Delete Button
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: Color(0xFFDC2626),
                          ),
                          tooltip: 'Delete Banner',
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFEE2E2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(7),
                          ),
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
    );
  }

  String _getLinkDescription() {
    switch (banner.linkType.toLowerCase()) {
      case 'product':
        return 'Product #${banner.linkId ?? ''}';
      case 'category':
        return 'Category #${banner.linkId ?? ''}';
      case 'external':
        return 'External URL';
      case 'none':
      default:
        return 'No Link';
    }
  }
}
