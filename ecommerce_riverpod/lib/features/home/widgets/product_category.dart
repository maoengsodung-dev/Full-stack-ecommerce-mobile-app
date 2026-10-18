import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../providers/home_provider.dart';

class ProductCategory extends ConsumerWidget {
  const ProductCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final selectedId = homeState.selectedCategory;

    return homeState.categories.when(
      loading: () => Container(
        height: 92,
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (context, i) => const SizedBox(width: 14),
          itemBuilder: (context, i) => Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 45,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        return Container(
          height: 92,
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedId == null;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(homeNotifierProvider.notifier)
                        .selectCategory(null);
                  },
                  child: SizedBox(
                    width: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              AssetConstants.category,
                              color: isSelected
                                  ? AppColors.accentLight
                                  : AppColors.primary,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.all,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final cat = categories[index - 1];
              final isSelected = selectedId == cat.id;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(homeNotifierProvider.notifier)
                      .selectCategory(cat.id);
                },
                child: SizedBox(
                  width: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 56,
                        width: 56,

                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 0.9,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: cat.imageUrl!,
                                  height: 56,
                                  width: 56,

                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => SvgPicture.asset(
                                    AssetConstants.category,
                                    color: AppColors.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  AssetConstants.category,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
