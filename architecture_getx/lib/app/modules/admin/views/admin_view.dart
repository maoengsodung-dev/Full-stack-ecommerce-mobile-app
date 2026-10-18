import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/admin_controller.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../widgets/banner_card.dart';
import '../widgets/category_card.dart';
import '../widgets/order_card.dart';
import '../widgets/product_card.dart';
import 'banner/create_banner_view.dart';
import 'banner/update_banner_view.dart';
import 'category/create_category_view.dart';
import 'category/update_category_view.dart';
import 'order/update_order_status_view.dart';
import 'product/create_product_view.dart';
import 'product/update_product_view.dart';
import 'variant/add_variant_view.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Store Catalog & Operations',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 19,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            tooltip: 'Refresh All',
            onPressed: () => controller.loadAll(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Obx(() {
        switch (controller.tabIndex.value) {
          case 1:
            return _buildProductsTab(context, controller);
          case 2:
            return _buildCategoriesTab(context, controller);
          case 3:
            return _buildOrdersTab(context, controller);
          case 4:
            return _buildBannersTab(context, controller);
          case 0:
          default:
            return _buildOverviewTab(context, controller);
        }
      }),
      bottomNavigationBar: Obx(() {
        final _ = controller.tabIndex.value;
        const activeColor = Color(0xFF5B4DFF);
        const inactiveColor = Color(0xFF0F172A);

        return Container(
          color: const Color(0xFFF8FAFC),
          child: SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _buildAdminNavItem(
                    controller: controller,
                    index: 0,
                    label: 'Dashboard',
                    activeIcon: SvgPicture.asset(
                      AssetConstants.overviewCack,
                      color: activeColor,
                      width: 24,
                      height: 24,
                    ),
                    inactiveIcon: SvgPicture.asset(
                      AssetConstants.overView,
                      color: inactiveColor,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  _buildAdminNavItem(
                    controller: controller,
                    index: 1,
                    label: 'Products',
                    activeIcon: SvgPicture.asset(
                      AssetConstants.productCheck,
                      color: activeColor,
                      width: 24,
                      height: 24,
                    ),
                    inactiveIcon: SvgPicture.asset(
                      AssetConstants.product,
                      color: inactiveColor,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  _buildAdminNavItem(
                    controller: controller,
                    index: 2,
                    label: 'Categories',
                    activeIcon: SvgPicture.asset(
                      AssetConstants.categoryCheck,
                      color: activeColor,
                      width: 24,
                      height: 24,
                    ),
                    inactiveIcon: SvgPicture.asset(
                      AssetConstants.category,
                      color: inactiveColor,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  _buildAdminNavItem(
                    controller: controller,
                    index: 3,
                    label: 'Orders',
                    activeIcon: SvgPicture.asset(
                      AssetConstants.orderCheck,
                      color: activeColor,
                      width: 24,
                      height: 24,
                    ),
                    inactiveIcon: SvgPicture.asset(
                      AssetConstants.order,
                      color: inactiveColor,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  _buildAdminNavItem(
                    controller: controller,
                    index: 4,
                    label: 'Banners',
                    activeIcon: const Icon(
                      Icons.view_carousel_rounded,
                      color: activeColor,
                      size: 24,
                    ),
                    inactiveIcon: const Icon(
                      Icons.view_carousel_outlined,
                      color: inactiveColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAdminNavItem({
    required AdminController controller,
    required int index,
    required String label,
    required Widget activeIcon,
    required Widget inactiveIcon,
  }) {
    final isSelected = controller.tabIndex.value == index;
    const activeColor = Color(0xFF5B4DFF);
    const inactiveTextColor = Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.setTab(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey('${index}_$isSelected'),
                  child: isSelected ? activeIcon : inactiveIcon,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveTextColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. OVERVIEW TAB

  Widget _buildOverviewTab(BuildContext context, AdminController controller) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return RefreshIndicator(
      onRefresh: controller.loadAll,
      color: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Revenue',
                    value: currencyFormatter.format(controller.totalRevenue),
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFDCFCE7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Orders',
                    value: controller.totalOrders.toString(),
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFDBEAFE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Pending',
                    value: controller.pendingOrders.toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Delivered',
                    value: controller.deliveredOrders.toString(),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFD1FAE5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Products',
                    value: controller.totalProducts.toString(),
                    icon: Icons.layers_rounded,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFEDE9FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    label: 'Add Product',
                    sub: 'New catalog item',
                    icon: Icons.add_box_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => Get.to(() => const CreateProductView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    label: 'Add Category',
                    sub: 'Taxonomy setup',
                    icon: Icons.create_new_folder_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => Get.to(() => const CreateCategoryView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    label: 'Add Banner',
                    sub: 'Sliders & promos',
                    icon: Icons.add_photo_alternate_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => Get.to(() => const CreateBannerView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    label: 'Manage Banners',
                    sub: 'View all promotions',
                    icon: Icons.view_carousel_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => controller.setTab(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => controller.setTab(3),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (controller.orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'No orders placed yet.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ...controller.orders.take(3).map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(
                    order: order,
                    onUpdateStatus: () {
                      Get.to(
                        () => const UpdateOrderStatusView(),
                        arguments: order,
                      );
                    },
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Top Products Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Catalog Products',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => controller.setTab(1),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (controller.products.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'No products available.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ...controller.products.take(3).map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCard(
                    product: product,
                    onEdit: () {
                      Get.to(
                        () => const UpdateProductView(),
                        arguments: product,
                      );
                    },
                    onAddVariant: () {
                      Get.to(() => const AddVariantView(), arguments: product);
                    },
                    onDelete: () =>
                        _confirmDeleteProduct(context, controller, product),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // 2. PRODUCTS TAB

  Widget _buildProductsTab(BuildContext context, AdminController controller) {
    return Column(
      children: [
        // Header Controls: Search & Add Product
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: controller.setProductSearch,
                        decoration: InputDecoration(
                          hintText: 'Search products by name or category...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AssetConstants.search,
                              width: 24,
                              height: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const CreateProductView()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: Obx(() {
                    final selected = controller.productCategoryFilter.value;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        if (idx == 0) {
                          final isAll = selected.isEmpty;
                          return InkWell(
                            onTap: () =>
                                controller.setProductCategoryFilter(''),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isAll
                                    ? AppColors.primaryLight
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'All Categories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isAll
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final cat = controller.categories[idx - 1];
                        final isSel = selected == cat.name;
                        return InkWell(
                          onTap: () =>
                              controller.setProductCategoryFilter(cat.name),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primaryLight
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Product List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingProducts.value &&
                controller.products.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F172A)),
              );
            }

            final list = controller.filteredProducts;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AssetConstants.product,
                        width: 50,
                        height: 50,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadProducts,
              color: const Color(0xFF0F172A),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final AdminProduct product = list[index];
                  return ProductCard(
                    product: product,
                    onEdit: () {
                      Get.to(
                        () => const UpdateProductView(),
                        arguments: product,
                      );
                    },
                    onAddVariant: () {
                      Get.to(() => const AddVariantView(), arguments: product);
                    },
                    onDelete: () =>
                        _confirmDeleteProduct(context, controller, product),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 3. CATEGORIES TAB

  Widget _buildCategoriesTab(BuildContext context, AdminController controller) {
    return Column(
      children: [
        // Header: Search & Add Category
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: controller.setCategorySearch,
                    decoration: const InputDecoration(
                      hintText: 'Search categories by name or slug...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const CreateCategoryView()),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Categories List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingCategories.value &&
                controller.categories.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F172A)),
              );
            }

            final list = controller.filteredCategories;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AssetConstants.category,
                        width: 50,
                        height: 50,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No categories found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadCategories,
              color: const Color(0xFF0F172A),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final AdminCategory cat = list[index];
                  return CategoryCard(
                    category: cat,
                    onTap: () {
                      Get.to(() => const UpdateCategoryView(), arguments: cat);
                    },
                    onEdit: () {
                      Get.to(() => const UpdateCategoryView(), arguments: cat);
                    },
                    onDelete: () =>
                        _confirmDeleteCategory(context, controller, cat),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 4. ORDERS TAB

  Widget _buildOrdersTab(BuildContext context, AdminController controller) {
    final statusFilters = [
      {'key': 'all', 'label': 'All Orders'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'processing', 'label': 'Processing'},
      {'key': 'shipped', 'label': 'Shipped'},
      {'key': 'delivered', 'label': 'Delivered'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return Column(
      children: [
        // Search & Status filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: controller.setOrderSearch,
                  decoration: InputDecoration(
                    hintText: 'Search order #, customer, tracking...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        AssetConstants.search,
                        width: 24,
                        height: 24,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: Obx(() {
                  final current = controller.orderStatusFilter.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final item = statusFilters[idx];
                      final isSel =
                          current.toLowerCase() == item['key']!.toLowerCase();

                      return InkWell(
                        onTap: () =>
                            controller.setOrderStatusFilter(item['key']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryLight
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Orders List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingOrders.value && controller.orders.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F172A)),
              );
            }

            final list = controller.filteredOrders;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadOrders,
              color: const Color(0xFF0F172A),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final AdminOrder order = list[index];
                  return OrderCard(
                    order: order,
                    onUpdateStatus: () {
                      Get.to(
                        () => const UpdateOrderStatusView(),
                        arguments: order,
                      );
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // 5. BANNERS TAB

  Widget _buildBannersTab(BuildContext context, AdminController controller) {
    final positions = [
      {'key': '', 'label': 'All Banners'},
      {'key': 'home_slider', 'label': 'Home Slider'},
      {'key': 'home_banner', 'label': 'Home Banner'},
      {'key': 'promo', 'label': 'Promo'},
      {'key': 'popup', 'label': 'Popup'},
    ];

    return Column(
      children: [
        // Header: Search & Add Banner
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: controller.setBannerSearch,
                        decoration: InputDecoration(
                          hintText: 'Search banners by title or position...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AssetConstants.search,
                              width: 24,
                              height: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const CreateBannerView()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: Obx(() {
                  final selected = controller.bannerPositionFilter.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: positions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final item = positions[idx];
                      final isSel =
                          selected.toLowerCase() == item['key']!.toLowerCase();

                      return InkWell(
                        onTap: () =>
                            controller.setBannerPositionFilter(item['key']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryLight
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Banners List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingBanners.value &&
                controller.banners.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0F172A)),
              );
            }

            final list = controller.filteredBanners;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.view_carousel_outlined,
                        size: 44,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No banners found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create promotional banners for the app homepage',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const CreateBannerView()),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Banner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadBanners,
              color: const Color(0xFF0F172A),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final AdminBanner banner = list[index];
                  return BannerCard(
                    banner: banner,
                    onEdit: () {
                      Get.to(() => const UpdateBannerView(), arguments: banner);
                    },
                    onDelete: () =>
                        _confirmDeleteBanner(context, controller, banner),
                    onToggleActive: (val) =>
                        controller.toggleBannerStatus(banner),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // HELPER WIDGETS

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildActionTile({
    required String label,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(
    BuildContext context,
    AdminController controller,
    AdminProduct product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: Size.zero),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    AdminController controller,
    AdminCategory category,
  ) {
    final hasProducts = category.productsCount > 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delete Category',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${category.name}"?',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            if (hasProducts)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This category has ${category.productsCount} products. The server will prevent deletion until all assigned products are reassigned or removed.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'This action is irreversible. The category will be permanently removed from the catalog.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: Size.zero),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteCategory(category.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBanner(
    BuildContext context,
    AdminController controller,
    AdminBanner banner,
  ) {
    final title = banner.title?.isNotEmpty == true
        ? banner.title!
        : 'Banner #${banner.id}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delete Banner',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This banner will no longer be visible in the catalog or mobile app.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: Size.zero),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteBanner(banner.id);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
