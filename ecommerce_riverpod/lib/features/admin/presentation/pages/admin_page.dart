import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/constants/asset_constants.dart';
import '../../../../app/core/providers/storage_providers.dart';
import '../../../../app/core/router/route_names.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/utils/l10n_extensions.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/banner_card.dart';
import '../widgets/category_card.dart';
import '../widgets/order_card.dart';
import '../widgets/product_card.dart';
import 'banner/create_banner_page.dart';
import 'banner/update_banner_page.dart';
import 'category/create_category_page.dart';
import 'category/update_category_page.dart';
import 'order/update_order_status_page.dart';
import 'product/create_product_page.dart';
import 'product/update_product_page.dart';
import 'variant/add_variant_page.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _bannerSearchController = TextEditingController();
  final TextEditingController _orderSearchController = TextEditingController();

  String _productSearch = '';
  String _productCategoryFilter = '';
  String _categorySearch = '';
  String _bannerSearch = '';
  String _orderSearch = '';
  String _orderStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminNotifierProvider.notifier).fetchDashboard(showLoading: false);
    });
  }

  @override
  void dispose() {
    _productSearchController.dispose();
    _categorySearchController.dispose();
    _bannerSearchController.dispose();
    _orderSearchController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          context.l10n.logout,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(context.l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.logout,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final storage = ref.read(storageServiceProvider);
      await storage.removeToken();
      await storage.removeAdminToken();
      await ref.read(authNotifierProvider.notifier).logout();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final notifier = ref.read(adminNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: SvgPicture.asset(
              AssetConstants.logout,
              colorFilter: const ColorFilter.mode(
                AppColors.error,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _buildCurrentTab(context, adminState, notifier),
      bottomNavigationBar: _buildBottomNav(adminState.selectedTab, notifier),
    );
  }

  Widget _buildCurrentTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    switch (state.selectedTab) {
      case 1:
        return _buildProductsTab(context, state, notifier);
      case 2:
        return _buildCategoriesTab(context, state, notifier);
      case 3:
        return _buildOrdersTab(context, state, notifier);
      case 4:
        return _buildBannersTab(context, state, notifier);
      case 0:
      default:
        return _buildOverviewTab(context, state, notifier);
    }
  }

  Widget _buildBottomNav(int selectedTab, AdminNotifier notifier) {
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
              _buildNavItem(
                index: 0,
                currentIndex: selectedTab,
                notifier: notifier,
                label: 'Dashboard',
                activeIcon: SvgPicture.asset(
                  AssetConstants.overviewCack,
                  colorFilter: const ColorFilter.mode(
                    activeColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
                inactiveIcon: SvgPicture.asset(
                  AssetConstants.overView,
                  colorFilter: const ColorFilter.mode(
                    inactiveColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              _buildNavItem(
                index: 1,
                currentIndex: selectedTab,
                notifier: notifier,
                label: 'Products',
                activeIcon: SvgPicture.asset(
                  AssetConstants.productCheck,
                  colorFilter: const ColorFilter.mode(
                    activeColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
                inactiveIcon: SvgPicture.asset(
                  AssetConstants.product,
                  colorFilter: const ColorFilter.mode(
                    inactiveColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              _buildNavItem(
                index: 2,
                currentIndex: selectedTab,
                notifier: notifier,
                label: 'Categories',
                activeIcon: SvgPicture.asset(
                  AssetConstants.categoryCheck,
                  colorFilter: const ColorFilter.mode(
                    activeColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
                inactiveIcon: SvgPicture.asset(
                  AssetConstants.category,
                  colorFilter: const ColorFilter.mode(
                    inactiveColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              _buildNavItem(
                index: 3,
                currentIndex: selectedTab,
                notifier: notifier,
                label: 'Orders',
                activeIcon: SvgPicture.asset(
                  AssetConstants.orderCheck,
                  colorFilter: const ColorFilter.mode(
                    activeColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
                inactiveIcon: SvgPicture.asset(
                  AssetConstants.order,
                  colorFilter: const ColorFilter.mode(
                    inactiveColor,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              _buildNavItem(
                index: 4,
                currentIndex: selectedTab,
                notifier: notifier,
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
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required AdminNotifier notifier,
    required String label,
    required Widget activeIcon,
    required Widget inactiveIcon,
  }) {
    final isSelected = currentIndex == index;
    const activeColor = Color(0xFF5B4DFF);
    const inactiveTextColor = Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => notifier.setTab(index),
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
  Widget _buildOverviewTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    final orders = state.orders.valueOrNull ?? [];
    final products = state.products.valueOrNull ?? [];

    final double totalRevenue = orders.fold(
      0.0,
      (sum, o) => sum + (o.isPaid ? o.total : 0.0),
    );
    final int totalOrders = orders.length;
    final int pendingOrders = orders
        .where((o) => o.status.toLowerCase() == 'pending')
        .length;
    final int deliveredOrders = orders
        .where((o) => o.status.toLowerCase() == 'delivered')
        .length;
    final int totalProducts = products.length;

    return RefreshIndicator(
      onRefresh: () => notifier.fetchDashboard(),
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
                    value: currencyFormatter.format(totalRevenue),
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFDCFCE7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Orders',
                    value: totalOrders.toString(),
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
                    value: pendingOrders.toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Delivered',
                    value: deliveredOrders.toString(),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFD1FAE5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Products',
                    value: totalProducts.toString(),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateProductPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    label: 'Add Category',
                    sub: 'Taxonomy setup',
                    icon: Icons.create_new_folder_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateCategoryPage(),
                      ),
                    ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateBannerPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    label: 'Manage Banners',
                    sub: 'View all promotions',
                    icon: Icons.view_carousel_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => notifier.setTab(4),
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
                  onPressed: () => notifier.setTab(3),
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

            if (orders.isEmpty)
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
              ...orders.take(3).map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(
                    order: order,
                    onUpdateStatus: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UpdateOrderStatusPage(order: order),
                        ),
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
                  onPressed: () => notifier.setTab(1),
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

            if (products.isEmpty)
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
              ...products.take(3).map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductCard(
                    product: product,
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UpdateProductPage(product: product),
                        ),
                      );
                    },
                    onAddVariant: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddVariantPage(product: product),
                        ),
                      );
                    },
                    onDelete: () =>
                        _confirmDeleteProduct(context, notifier, product),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // 2. PRODUCTS TAB
  Widget _buildProductsTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    final categories = state.categories.valueOrNull ?? [];

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
                        controller: _productSearchController,
                        onChanged: (val) {
                          setState(() {
                            _productSearch = val.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products by name or category...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              AssetConstants.search,
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.textSecondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          suffixIcon: _productSearch.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    _productSearchController.clear();
                                    setState(() {
                                      _productSearch = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateProductPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.primary,
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
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      if (idx == 0) {
                        final isAll = _productCategoryFilter.isEmpty;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _productCategoryFilter = '';
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isAll
                                  ? AppColors.primary
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

                      final cat = categories[idx - 1];
                      final isSel = _productCategoryFilter == cat.name;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _productCategoryFilter = cat.name;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary
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
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Product List
        Expanded(
          child: state.products.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => notifier.fetchProducts(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            data: (allProducts) {
              final filtered = allProducts.where((p) {
                final matchQuery =
                    _productSearch.isEmpty ||
                    p.name.toLowerCase().contains(_productSearch) ||
                    (p.categoryName ?? '').toLowerCase().contains(
                      _productSearch,
                    );
                final matchCat =
                    _productCategoryFilter.isEmpty ||
                    p.categoryName == _productCategoryFilter;
                return matchQuery && matchCat;
              }).toList();

              if (filtered.isEmpty) {
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
                          colorFilter: const ColorFilter.mode(
                            AppColors.accentBlue,
                            BlendMode.srcIn,
                          ),
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
                onRefresh: () => notifier.fetchProducts(),
                color: const Color(0xFF0F172A),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final AdminProduct product = filtered[index];
                    return ProductCard(
                      product: product,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UpdateProductPage(product: product),
                          ),
                        );
                      },
                      onAddVariant: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddVariantPage(product: product),
                          ),
                        );
                      },
                      onDelete: () =>
                          _confirmDeleteProduct(context, notifier, product),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. CATEGORIES TAB
  Widget _buildCategoriesTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    return Column(
      children: [
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
                    controller: _categorySearchController,
                    onChanged: (val) {
                      setState(() {
                        _categorySearch = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          AssetConstants.search,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffixIcon: _categorySearch.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                _categorySearchController.clear();
                                setState(() {
                                  _categorySearch = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: AppColors.primary,
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

        Expanded(
          child: state.categories.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => notifier.fetchCategories(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            data: (allCategories) {
              final filtered = allCategories.where((c) {
                return _categorySearch.isEmpty ||
                    c.name.toLowerCase().contains(_categorySearch);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => notifier.fetchCategories(),
                color: const Color(0xFF0F172A),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final AdminCategory cat = filtered[index];
                    return CategoryCard(
                      category: cat,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UpdateCategoryPage(category: cat),
                          ),
                        );
                      },
                      onDelete: () =>
                          _confirmDeleteCategory(context, notifier, cat),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. ORDERS TAB
  Widget _buildOrdersTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    final statusFilters = const [
      {'key': 'all', 'label': 'All Orders'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'processing', 'label': 'Processing'},
      {'key': 'shipped', 'label': 'Shipped'},
      {'key': 'delivered', 'label': 'Delivered'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _orderSearchController,
                  onChanged: (val) {
                    setState(() {
                      _orderSearch = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search order #, customer, tracking...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    suffixIcon: _orderSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            onPressed: () {
                              _orderSearchController.clear();
                              setState(() {
                                _orderSearch = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final f = statusFilters[idx];
                    final isSelected =
                        _orderStatusFilter.toLowerCase() ==
                        f['key']!.toLowerCase();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _orderStatusFilter = f['key']!;
                        });
                        notifier.fetchOrders(
                          status: f['key'] == 'all' ? null : f['key'],
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            f['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: state.orders.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => notifier.fetchOrders(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            data: (allOrders) {
              final filtered = allOrders.where((order) {
                if (_orderSearch.isEmpty) return true;
                final orderNum = order.orderNumber.toLowerCase();
                final userEmail = (order.userEmail ?? '').toLowerCase();
                final userName = (order.userName ?? '').toLowerCase();
                final tracking = (order.trackingNumber ?? '').toLowerCase();
                return orderNum.contains(_orderSearch) ||
                    userEmail.contains(_orderSearch) ||
                    userName.contains(_orderSearch) ||
                    tracking.contains(_orderSearch);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => notifier.fetchOrders(
                  status: _orderStatusFilter == 'all'
                      ? null
                      : _orderStatusFilter,
                ),
                color: const Color(0xFF0F172A),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final AdminOrder order = filtered[index];
                    return OrderCard(
                      order: order,
                      onUpdateStatus: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UpdateOrderStatusPage(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 5. BANNERS TAB
  Widget _buildBannersTab(
    BuildContext context,
    AdminState state,
    AdminNotifier notifier,
  ) {
    return Column(
      children: [
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
                    controller: _bannerSearchController,
                    onChanged: (val) {
                      setState(() {
                        _bannerSearch = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search banners by title...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          AssetConstants.search,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffixIcon: _bannerSearch.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                _bannerSearchController.clear();
                                setState(() {
                                  _bannerSearch = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateBannerPage()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: AppColors.primary,
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

        Expanded(
          child: state.banners.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    err.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => notifier.fetchBanners(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
            data: (allBanners) {
              final filtered = allBanners.where((b) {
                return _bannerSearch.isEmpty ||
                    (b.title ?? '').toLowerCase().contains(_bannerSearch) ||
                    (b.subtitle ?? '').toLowerCase().contains(_bannerSearch);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No banners found',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => notifier.fetchBanners(),
                color: const Color(0xFF0F172A),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final AdminBanner banner = filtered[index];
                    return BannerCard(
                      banner: banner,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UpdateBannerPage(banner: banner),
                          ),
                        );
                      },
                      onDelete: () =>
                          _confirmDeleteBanner(context, notifier, banner),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // HELPER METRIC & ACTION TILES
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
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
    AdminNotifier notifier,
    AdminProduct product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await notifier.deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Product deleted successfully'
                          : 'Failed to delete product',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    AdminNotifier notifier,
    AdminCategory category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await notifier.deleteCategory(category.id);
              if (context.mounted) {
                final err = ref.read(adminNotifierProvider).actionState.error?.toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Category deleted successfully'
                          : (err ?? 'Failed to delete category'),
                    ),
                    backgroundColor:
                        success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBanner(
    BuildContext context,
    AdminNotifier notifier,
    AdminBanner banner,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner'),
        content: Text(
          'Are you sure you want to delete "${banner.title ?? 'Banner #${banner.id}'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await notifier.deleteBanner(banner.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Banner deleted successfully'
                          : 'Failed to delete banner',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
