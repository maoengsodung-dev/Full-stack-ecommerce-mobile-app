import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';
import '../controllers/home_controller.dart';

class ProductCategory extends GetView<HomeController> {
  const ProductCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = controller.categories;
      final selectedId = controller.selectedCategory.value;
      final isLoading = controller.isLoadingCategories.value;

      if (isLoading && categories.isEmpty) {
        return Container(
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
        );
      }

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
            // Index 0: "All"
            if (index == 0) {
              final isSelected = selectedId == null;

              return GestureDetector(
                onTap: () {
                  controller.setCategory(null);
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
                              ? AppColors.primaryLight
                              : AppColors.primaryLight.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AssetConstants.all,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.all,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryLight
                              : const Color(0xFF4B5563),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final category = categories[index - 1];
            final isSelected = selectedId == category.id;

            return GestureDetector(
              onTap: () {
                // Keep the selected category active even if clicked again (do not toggle to all)
                controller.setCategory(category.id);
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
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight
                              : Colors.grey.shade200,
                          width: isSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryLight.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            category.image != null &&
                                category.image!.trim().isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: category.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.08,
                                  ),
                                  child: Icon(
                                    Icons.category_outlined,
                                    size: 24,
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.08,
                                ),
                                child: Icon(
                                  Icons.category_rounded,
                                  size: 24,
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : Colors.grey.shade600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryLight
                            : const Color(0xFF4B5563),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
