import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../providers/admin_provider.dart';

class AdminController extends GetxController {
  final AdminProvider _provider;

  AdminController({AdminProvider? provider})
    : _provider =
          provider ??
          (Get.isRegistered<AdminProvider>()
              ? Get.find<AdminProvider>()
              : AdminProvider());

  // Active Tab Index (0: Dashboard Overview, 1: Products, 2: Categories, 3: Orders, 4: Banners)
  final tabIndex = 0.obs;

  // Observable Collections
  final categories = <AdminCategory>[].obs;
  final products = <AdminProduct>[].obs;
  final orders = <AdminOrder>[].obs;
  final banners = <AdminBanner>[].obs;

  // Loading States
  final isLoadingCategories = false.obs;
  final isLoadingProducts = false.obs;
  final isLoadingOrders = false.obs;
  final isLoadingBanners = false.obs;
  final isSubmitting = false.obs;

  // Error Messages
  final categoriesError = ''.obs;
  final productsError = ''.obs;
  final ordersError = ''.obs;
  final bannersError = ''.obs;

  // Filter & Search Controls
  final orderStatusFilter = 'all'.obs;
  final orderPaymentStatusFilter = 'all'.obs;
  final productSearchQuery = ''.obs;
  final productCategoryFilter = ''.obs;
  final categorySearchQuery = ''.obs;
  final orderSearchQuery = ''.obs;
  final bannerSearchQuery = ''.obs;
  final bannerPositionFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void setTab(int index) {
    tabIndex.value = index;
  }

  // KPI Getters
  int get totalOrders => orders.length;
  double get totalRevenue => orders.fold(0.0, (sum, o) => sum + o.total);
  int get pendingOrders =>
      orders.where((o) => o.status.toLowerCase() == 'pending').length;
  int get processingOrders =>
      orders.where((o) => o.status.toLowerCase() == 'processing').length;
  int get shippedOrders =>
      orders.where((o) => o.status.toLowerCase() == 'shipped').length;
  int get deliveredOrders =>
      orders.where((o) => o.status.toLowerCase() == 'delivered').length;
  int get cancelledOrders =>
      orders.where((o) => o.status.toLowerCase() == 'cancelled').length;
  int get totalProducts => products.length;
  int get totalCategories => categories.length;
  int get totalBanners => banners.length;
  int get activeBanners => banners.where((b) => b.isActive).length;

  //  Filtered Collections
  List<AdminCategory> get filteredCategories {
    final query = categorySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return categories;
    return categories.where((cat) {
      return cat.name.toLowerCase().contains(query) ||
          cat.slug.toLowerCase().contains(query) ||
          (cat.description != null &&
              cat.description!.toLowerCase().contains(query));
    }).toList();
  }

  List<AdminProduct> get filteredProducts {
    final query = productSearchQuery.value.trim().toLowerCase();
    final catFilter = productCategoryFilter.value.trim().toLowerCase();

    return products.where((prod) {
      final matchesQuery =
          query.isEmpty ||
          prod.name.toLowerCase().contains(query) ||
          prod.slug.toLowerCase().contains(query) ||
          (prod.categoryName != null &&
              prod.categoryName!.toLowerCase().contains(query));

      final matchesCategory =
          catFilter.isEmpty ||
          (prod.categoryName != null &&
              prod.categoryName!.toLowerCase() == catFilter) ||
          (prod.categoryId != null && prod.categoryId.toString() == catFilter);

      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<AdminOrder> get filteredOrders {
    final query = orderSearchQuery.value.trim().toLowerCase();
    return orders.where((order) {
      if (query.isEmpty) return true;
      return order.orderNumber.toLowerCase().contains(query) ||
          (order.customerName != null &&
              order.customerName!.toLowerCase().contains(query)) ||
          (order.trackingNumber != null &&
              order.trackingNumber!.toLowerCase().contains(query));
    }).toList();
  }

  List<AdminBanner> get filteredBanners {
    final query = bannerSearchQuery.value.trim().toLowerCase();
    final pos = bannerPositionFilter.value.trim().toLowerCase();
    return banners.where((b) {
      final matchesQuery =
          query.isEmpty ||
          (b.title != null && b.title!.toLowerCase().contains(query)) ||
          (b.subtitle != null && b.subtitle!.toLowerCase().contains(query)) ||
          b.position.toLowerCase().contains(query) ||
          b.linkType.toLowerCase().contains(query);

      final matchesPos = pos.isEmpty || b.position.toLowerCase() == pos;
      return matchesQuery && matchesPos;
    }).toList();
  }

  // Master Loader
  Future<void> loadAll() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
      loadOrders(),
      loadBanners(),
    ]);
  }

  // Categories
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      categoriesError.value = '';
      final result = await _provider.getCategories();
      categories.assignAll(result);
    } catch (e) {
      categoriesError.value = e.toString();
      debugPrint('[AdminController] loadCategories error: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<bool> createCategory({
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
    try {
      isSubmitting.value = true;
      final newCat = await _provider.createCategory(
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        imageFile: imageFile,
      );
      categories.insert(0, newCat);
      Get.snackbar(
        'Category Created',
        'Category "${newCat.name}" was added successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      String message = 'Failed to create category';
      if (e is DioException) {
        message = e.response?.data?['message'] ?? e.message ?? message;
      } else {
        message = e.toString();
      }
      Get.snackbar(
        'Failed to Create Category',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateCategory(
    int id, {
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
    try {
      isSubmitting.value = true;
      final updatedCat = await _provider.updateCategory(
        id,
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        imageFile: imageFile,
      );
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = updatedCat;
      } else {
        await loadCategories();
      }
      Get.snackbar(
        'Category Updated',
        'Category "${updatedCat.name}" was updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      String message = 'Failed to update category';
      if (e is DioException) {
        message = e.response?.data?['message'] ?? e.message ?? message;
      } else {
        message = e.toString();
      }
      Get.snackbar(
        'Failed to Update Category',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      isSubmitting.value = true;
      await _provider.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Category Deleted',
        'Category was deleted successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      String message = 'Failed to delete category';
      if (e is DioException) {
        message = e.response?.data?['message'] ?? e.message ?? message;
      } else {
        message = e.toString();
      }
      Get.snackbar(
        'Failed to Delete Category',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Products
  Future<void> loadProducts() async {
    try {
      isLoadingProducts.value = true;
      productsError.value = '';
      final result = await _provider.getProducts(
        search: productSearchQuery.value.isNotEmpty
            ? productSearchQuery.value
            : null,
        category: productCategoryFilter.value.isNotEmpty
            ? productCategoryFilter.value
            : null,
      );
      products.assignAll(result);
    } catch (e) {
      productsError.value = e.toString();
      debugPrint('[AdminController] loadProducts error: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required String shortDescription,
    required double price,
    double? salePrice,
    required int stock,
    required int categoryId,
    String status = 'active',
    bool isFeatured = true,
    List<Map<String, dynamic>> images = const [],
    File? imageFile,
    List<File> imageFiles = const [],
  }) async {
    try {
      isSubmitting.value = true;
      final newProduct = await _provider.createProduct(
        name: name,
        description: description,
        shortDescription: shortDescription,
        price: price,
        salePrice: salePrice,
        stock: stock,
        categoryId: categoryId,
        status: status,
        isFeatured: isFeatured,
        images: images,
        imageFile: imageFile,
        imageFiles: imageFiles,
      );
      products.insert(0, newProduct);
      Get.snackbar(
        'Product Created',
        'Product "${newProduct.name}" created successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Create Product',
        _parseErrorMessage(e, 'Failed to create product'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateProduct(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<File> imageFiles = const [],
    List<String>? existingImageUrls,
  }) async {
    try {
      isSubmitting.value = true;
      await _provider.updateProduct(
        id,
        data,
        imageFile: imageFile,
        imageFiles: imageFiles,
        existingImageUrls: existingImageUrls,
      );
      await loadProducts();
      Get.snackbar(
        'Product Updated',
        'Product #$id was updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Update Product',
        _parseErrorMessage(e, 'Failed to update product'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      isSubmitting.value = true;
      await _provider.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Delete Product',
        _parseErrorMessage(e, 'Failed to delete product'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Variants
  Future<bool> addVariant(int productId, AdminVariant variant) async {
    try {
      isSubmitting.value = true;
      await _provider.addVariant(productId, variant);
      await loadProducts();
      Get.snackbar(
        'Variant Added',
        'Variant SKU "${variant.sku}" added to product #$productId.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Add Variant',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> addMultipleVariants(int productId, List<AdminVariant> variants) async {
    if (variants.isEmpty) return false;
    try {
      isSubmitting.value = true;
      int successCount = 0;
      final errors = <String>[];
      for (final v in variants) {
        try {
          await _provider.addVariant(productId, v);
          successCount++;
        } catch (e) {
          debugPrint('[AdminController] failed to add variant ${v.sku}: $e');
          errors.add('${v.sku}: $e');
        }
      }
      await loadProducts();
      if (successCount > 0) {
        Get.snackbar(
          'Variants Added',
          'Successfully added $successCount of ${variants.length} variant${variants.length > 1 ? 's' : ''}.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        return true;
      } else {
        Get.snackbar(
          'Failed to Add Variants',
          errors.isNotEmpty ? errors.first : 'Could not add variants. Please check SKU uniqueness.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Failed to Add Variants',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  //  Orders
  Future<void> loadOrders() async {
    try {
      isLoadingOrders.value = true;
      ordersError.value = '';
      final result = await _provider.getOrders(
        status: orderStatusFilter.value,
        paymentStatus: orderPaymentStatusFilter.value,
      );
      orders.assignAll(result);
    } catch (e) {
      ordersError.value = e.toString();
      debugPrint('[AdminController] loadOrders error: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<bool> updateOrderStatus(
    int orderId, {
    required String status,
    String? trackingNumber,
  }) async {
    try {
      isSubmitting.value = true;
      await _provider.updateOrderStatus(
        orderId,
        status: status,
        trackingNumber: trackingNumber,
      );
      await loadOrders();
      Get.snackbar(
        'Order Updated',
        'Order #$orderId marked as ${status.toUpperCase()}.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Update Order',
        _parseErrorMessage(e, 'Failed to update order status'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Banners (CRUD) ──────────────────────────────────────────────────────────
  Future<void> loadBanners() async {
    try {
      isLoadingBanners.value = true;
      bannersError.value = '';
      final result = await _provider.getBanners();
      banners.assignAll(result);
    } catch (e) {
      bannersError.value = e.toString();
      debugPrint('[AdminController] loadBanners error: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<bool> createBanner({
    String? title,
    String? subtitle,
    String? imageUrl,
    File? imageFile,
    String position = 'home_slider',
    bool isActive = true,
    int sortOrder = 0,
    String linkType = 'none',
    String? linkId,
    String? linkUrl,
    String? startAt,
    String? endAt,
  }) async {
    try {
      isSubmitting.value = true;
      final newBanner = await _provider.createBanner(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        imageFile: imageFile,
        position: position,
        isActive: isActive,
        sortOrder: sortOrder,
        linkType: linkType,
        linkId: linkId,
        linkUrl: linkUrl,
        startAt: startAt,
        endAt: endAt,
      );
      banners.insert(0, newBanner);
      Get.snackbar(
        'Banner Created',
        'Banner was created successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      final message = _parseErrorMessage(e, 'Failed to create banner');
      Get.snackbar(
        'Failed to Create Banner',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateBanner(
    int id, {
    String? title,
    String? subtitle,
    String? imageUrl,
    File? imageFile,
    String? position,
    bool? isActive,
    int? sortOrder,
    String? linkType,
    String? linkId,
    String? linkUrl,
    String? startAt,
    String? endAt,
  }) async {
    try {
      isSubmitting.value = true;
      final updatedBanner = await _provider.updateBanner(
        id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        imageFile: imageFile,
        position: position,
        isActive: isActive,
        sortOrder: sortOrder,
        linkType: linkType,
        linkId: linkId,
        linkUrl: linkUrl,
        startAt: startAt,
        endAt: endAt,
      );
      final index = banners.indexWhere((b) => b.id == id);
      if (index != -1) {
        banners[index] = updatedBanner;
      } else {
        await loadBanners();
      }
      Get.snackbar(
        'Banner Updated',
        'Banner was updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      final message = _parseErrorMessage(e, 'Failed to update banner');
      Get.snackbar(
        'Failed to Update Banner',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> toggleBannerStatus(AdminBanner banner) async {
    try {
      final newStatus = !banner.isActive;
      final index = banners.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        banners[index] = banner.copyWith(isActive: newStatus);
      }
      await _provider.updateBanner(
        banner.id,
        isActive: newStatus,
      );
      return true;
    } catch (e) {
      final index = banners.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        banners[index] = banner;
      }
      final message = _parseErrorMessage(e, 'Failed to toggle banner status');
      Get.snackbar(
        'Update Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    }
  }

  Future<bool> deleteBanner(int id) async {
    try {
      isSubmitting.value = true;
      await _provider.deleteBanner(id);
      banners.removeWhere((b) => b.id == id);
      Get.snackbar(
        'Banner Deleted',
        'Banner was successfully removed.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return true;
    } catch (e) {
      final message = _parseErrorMessage(e, 'Failed to delete banner');
      Get.snackbar(
        'Failed to Delete Banner',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  //  Search & Filter Setters
  void setBannerSearch(String query) {
    bannerSearchQuery.value = query;
  }

  void setBannerPositionFilter(String pos) {
    bannerPositionFilter.value = pos;
  }
  void setOrderStatusFilter(String status) {
    orderStatusFilter.value = status;
    loadOrders();
  }

  void setOrderPaymentFilter(String paymentStatus) {
    orderPaymentStatusFilter.value = paymentStatus;
    loadOrders();
  }

  void setProductSearch(String query) {
    productSearchQuery.value = query;
  }

  void setProductCategoryFilter(String category) {
    productCategoryFilter.value = category;
  }

  void setCategorySearch(String query) {
    categorySearchQuery.value = query;
  }

  void setOrderSearch(String query) {
    orderSearchQuery.value = query;
  }

  String _parseErrorMessage(dynamic e, String fallback) {
    if (e is DioException) {
      final resData = e.response?.data;
      if (resData is Map) {
        final msg = resData['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          if (e.response?.statusCode == 403 ||
              msg.toLowerCase().contains('role')) {
            return 'Permission Denied: Admin role required. ($msg)';
          }
          return msg;
        }
      }
      return e.message ?? fallback;
    }
    return e.toString();
  }
}
