import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/error/error_handler.dart';

import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/variant_model.dart';

class AdminState {
  final AsyncValue<List<AdminCategory>> categories;
  final AsyncValue<List<AdminProduct>> products;
  final AsyncValue<List<AdminOrder>> orders;
  final AsyncValue<List<AdminBanner>> banners;
  final AsyncValue<void> actionState;
  final int selectedTab;
  final String searchQuery;

  const AdminState({
    this.categories = const AsyncValue.loading(),
    this.products = const AsyncValue.loading(),
    this.orders = const AsyncValue.loading(),
    this.banners = const AsyncValue.loading(),
    this.actionState = const AsyncValue.data(null),
    this.selectedTab = 0,
    this.searchQuery = '',
  });

  AdminState copyWith({
    AsyncValue<List<AdminCategory>>? categories,
    AsyncValue<List<AdminProduct>>? products,
    AsyncValue<List<AdminOrder>>? orders,
    AsyncValue<List<AdminBanner>>? banners,
    AsyncValue<void>? actionState,
    int? selectedTab,
    String? searchQuery,
  }) {
    return AdminState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      orders: orders ?? this.orders,
      banners: banners ?? this.banners,
      actionState: actionState ?? this.actionState,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() {
    Future.microtask(() => fetchDashboard());
    return const AdminState();
  }

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
    if (index == 3) {
      fetchOrders(showLoading: false);
    } else if (index == 0) {
      fetchDashboard(showLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchDashboard({bool showLoading = true}) async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      fetchOrders(showLoading: showLoading),
      fetchBanners(),
    ]);
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(categories: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      final list = await ds.getCategories();
      state = state.copyWith(categories: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(categories: AsyncValue.error(e, st));
    }
  }

  Future<bool> createCategory({
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.createCategory(
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        imageFile: imageFile,
      );
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchCategories();
      return true;
    } catch (e, st) {
      final failure = ErrorHandler.handle(e);
      state = state.copyWith(actionState: AsyncValue.error(failure.message, st));
      return false;
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
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.updateCategory(
        id,
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        imageFile: imageFile,
      );
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchCategories();
      return true;
    } catch (e, st) {
      final failure = ErrorHandler.handle(e);
      state = state.copyWith(actionState: AsyncValue.error(failure.message, st));
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.deleteCategory(id);
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchCategories();
      return true;
    } catch (e, st) {
      final failure = ErrorHandler.handle(e);
      state = state.copyWith(actionState: AsyncValue.error(failure.message, st));
      return false;
    }
  }

  Future<void> fetchProducts({String? search, String? category}) async {
    state = state.copyWith(products: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      final list = await ds.getProducts(search: search, category: category);
      state = state.copyWith(products: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(products: AsyncValue.error(e, st));
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
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.createProduct(
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
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchProducts();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> updateProduct(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<File> imageFiles = const [],
    List<String>? existingImageUrls,
  }) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.updateProduct(
        id,
        data,
        imageFile: imageFile,
        imageFiles: imageFiles,
        existingImageUrls: existingImageUrls,
      );
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchProducts();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.deleteProduct(id);
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchProducts();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> addVariant(int productId, AdminVariant variant) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.addVariant(productId, variant);
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchProducts();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> addVariants(int productId, List<AdminVariant> variants) async {
    if (variants.isEmpty) return true;
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      for (final variant in variants) {
        await ds.addVariant(productId, variant);
      }
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchProducts();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<void> fetchOrders({
    String? status,
    String? paymentStatus,
    bool showLoading = true,
  }) async {
    if (showLoading || !state.orders.hasValue) {
      state = state.copyWith(orders: const AsyncValue.loading());
    }
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      final list =
          await ds.getOrders(status: status, paymentStatus: paymentStatus);
      state = state.copyWith(orders: AsyncValue.data(list));
    } catch (e, st) {
      if (!state.orders.hasValue) {
        state = state.copyWith(orders: AsyncValue.error(e, st));
      }
    }
  }

  Future<bool> updateOrderStatus(
    int orderId, {
    required String status,
    String? trackingNumber,
  }) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.updateOrderStatus(
        orderId,
        status: status,
        trackingNumber: trackingNumber,
      );
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchOrders();
      return true;
    } catch (e, st) {
      String errorMessage = 'Failed to update order status';
      if (e is DioException) {
        final failure = ErrorHandler.handle(e);
        errorMessage = failure.message;
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(actionState: AsyncValue.error(errorMessage, st));
      return false;
    }
  }

  Future<void> fetchBanners({String? search}) async {
    state = state.copyWith(banners: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      final list = await ds.getBanners(search: search);
      state = state.copyWith(banners: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(banners: AsyncValue.error(e, st));
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
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.createBanner(
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
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchBanners();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
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
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.updateBanner(
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
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchBanners();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }

  Future<bool> deleteBanner(int id) async {
    state = state.copyWith(actionState: const AsyncValue.loading());
    try {
      final ds = ref.read(adminRemoteDataSourceProvider);
      await ds.deleteBanner(id);
      state = state.copyWith(actionState: const AsyncValue.data(null));
      await fetchBanners();
      return true;
    } catch (e, st) {
      state = state.copyWith(actionState: AsyncValue.error(e, st));
      return false;
    }
  }
}

final adminNotifierProvider =
    NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);
