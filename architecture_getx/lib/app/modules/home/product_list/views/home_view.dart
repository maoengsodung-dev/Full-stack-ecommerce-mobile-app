import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/modules/home/product_list/widgets/banner_view.dart';
import 'package:architecture_getx/app/modules/home/product_list/widgets/product_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../notification/controllers/notification_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../../core/constants/icons.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../widgets/filter_bottom_sheet.dart';

import '../widgets/product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.welcome),

            // name user 
            Obx(() {
              final profileCtrl = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>()
                  : null;
              final name = (profileCtrl != null &&
                      profileCtrl.userName.isNotEmpty &&
                      profileCtrl.userName != 'Guest User')
                  ? profileCtrl.userName
                  : controller.userName;
              return Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              );
            }),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Obx(() {
              final notifCtrl = Get.isRegistered<NotificationController>()
                  ? Get.find<NotificationController>()
                  : null;
              final count = notifCtrl?.unreadCount ?? 0;

              return Badge.count(
                count: count,
                isLabelVisible: count > 0,
                backgroundColor: const Color(0xFFEF4444),
                offset: const Offset(-2, 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.NOTIFICATION);
                    },
                    icon: SvgPicture.asset(kNotification, width: 28, height: 28),
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search Bar & Filter Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    children: [
                      // Search TextField
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.SEARCH_PRODUCT);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xffF0F0F2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: TextField(
                              readOnly: true,
                              onTap: () {
                                Get.toNamed(Routes.SEARCH_PRODUCT);
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: context.l10n.whatsOnYourList,
                                hintStyle: const TextStyle(
                                  color: Color(0xffA0A0A5),
                                  fontSize: 14,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SvgPicture.asset(
                                    kSearch,
                                    color: Colors.grey,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Circular Black Filter Button
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            const FilterBottomSheet(),
                            isScrollControlled: true,
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration:  BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Slider Banner
              BannerView(),

              // Categories
              SliverToBoxAdapter(
                child: ProductCategory(),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    context.l10n.products,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // 3. Dynamic Products State (Loading / Error / Empty / Grid)
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage.value.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.fetchProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(context.l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (controller.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      context.l10n.noProductsFound,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return ProductCard(product: product);
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
