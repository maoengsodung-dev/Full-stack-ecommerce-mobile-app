import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../data/models/banner.model.dart';
import '../../../../data/models/product.model.dart';
import '../../../../data/providers/banner_provider.dart';
import '../../../../data/providers/category_provider.dart';
import '../../../../data/repository/banner_repository.dart';
import '../../../../data/repository/category_repository.dart';
import '../../../../data/repository/product_repository.dart';
import '../../../profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final ProductRepository _repository;
  final CategoryRepository _categoryRepository;
  final BannerRepository _bannerRepository;

  HomeController(
    this._repository, {
    CategoryRepository? categoryRepository,
    BannerRepository? bannerRepository,
  })  : _categoryRepository = categoryRepository ??
            (Get.isRegistered<CategoryRepository>()
                ? Get.find<CategoryRepository>()
                : CategoryRepository(Get.find<CategoryProvider>())),
        _bannerRepository = bannerRepository ??
            (Get.isRegistered<BannerRepository>()
                ? Get.find<BannerRepository>()
                : BannerRepository(Get.find<BannerProvider>()));

  // Banners State
  final banners = <BannerModel>[].obs;
  final isLoadingBanners = false.obs;
  final bannerErrorMessage = ''.obs;

  // Main Home Products State
  final isLoading = true.obs;
  final products = <ProductRes>[].obs;
  final errorMessage = ''.obs;

  // Categories State
  final categories = <CategoryModel>[].obs;
  final isLoadingCategories = false.obs;

  // Search State
  StorageService? get _storage =>
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;
  final searchController = TextEditingController();
  final searchText = ''.obs;
  final isSearching = false.obs;
  final searchResults = <ProductRes>[].obs;
  final searchErrorMessage = ''.obs;
  final searchSelectedCategory = RxnInt();
  final recentSearches = <String>[].obs;

  Timer? _searchTimer;

  // Filters
  final selectedCategory = RxnInt();

  final minPrice = RxnDouble();
  final maxPrice = RxnDouble();

  final featuredOnly = false.obs;
  final inStockOnly = true.obs;

  final selectedSort = '-created_at'.obs;

  /// User name resolved from ProfileController (account setting API) or storage cache
  String get userName {
    if (Get.isRegistered<ProfileController>()) {
      final name = Get.find<ProfileController>().userName;
      if (name.isNotEmpty && name != 'Guest User') return name;
    }
    final cached = _storage?.getUser();
    final name = cached?.name ?? cached?.data?.user?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Guest User';
  }

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    fetchBanners();
    fetchProducts();
    fetchCategories();
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchProfile();
    }
  }

  void _loadRecentSearches() {
    final list = _storage?.getRecentSearches() ?? [];
    recentSearches.assignAll(list);
  }

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    recentSearches.remove(trimmed);
    recentSearches.insert(0, trimmed);
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    _storage?.saveRecentSearches(recentSearches.toList());
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    _storage?.saveRecentSearches(recentSearches.toList());
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _storage?.saveRecentSearches([]);
  }

  void selectRecentSearch(String query) {
    searchController.text = query;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    searchText.value = query;
    addRecentSearch(query);
    searchProducts(query);
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchBanners(),
      fetchProducts(),
      fetchCategories(),
      if (Get.isRegistered<ProfileController>())
        Get.find<ProfileController>().fetchProfile(),
    ]);
  }

  Future<void> fetchBanners({String? position}) async {
    try {
      isLoadingBanners.value = true;
      bannerErrorMessage.value = '';
      final result = await _bannerRepository.getBanners(position: position);
      banners.assignAll(result);
    } catch (e) {
      bannerErrorMessage.value = e.toString();
      debugPrint('[HomeController] Error fetching banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final result = await _categoryRepository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts({dynamic category}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getProduct(
        perPage: 20,
        search: searchController.text.trim(),
        category: selectedCategory.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        featured: featuredOnly.value ? true : null,
        inStock: inStockOnly.value,
      );

      products.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Called on text field changes with a 400ms debounce
  void onSearchChanged(String query) {
    searchText.value = query;
    _searchTimer?.cancel();

    if (query.trim().isEmpty) {
      searchSelectedCategory.value = null;
      searchResults.clear();
      searchErrorMessage.value = '';
      isSearching.value = false;
      return;
    }

    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      searchProducts(query.trim());
    });
  }

  /// Performs the actual API search request
  Future<void> searchProducts(
    String query, {
    int? category,
    double? minPrice,
    double? maxPrice,
    int perPage = 20,
    bool addToRecent = false,
  }) async {
    final targetCategory =
        category ?? searchSelectedCategory.value ?? selectedCategory.value;
    final trimmed = query.trim();

    if (trimmed.isEmpty && targetCategory == null) {
      clearSearch();
      return;
    }

    if (addToRecent && trimmed.isNotEmpty) {
      addRecentSearch(trimmed);
    }

    try {
      isSearching.value = true;
      searchErrorMessage.value = '';

      final result = await _repository.getProduct(
        search: trimmed.isEmpty ? null : trimmed,
        perPage: perPage,
        category: targetCategory,
        minPrice: minPrice ?? this.minPrice.value,
        maxPrice: maxPrice ?? this.maxPrice.value,
        featured: featuredOnly.value ? true : null,
        inStock: inStockOnly.value,
      );

      searchResults.assignAll(result);
    } catch (e) {
      searchErrorMessage.value = e.toString();
    } finally {
      isSearching.value = false;
    }
  }

  /// Toggle category filter specifically in search screen
  void toggleSearchCategory(int? categoryId, [String? categoryName]) {
    if (searchSelectedCategory.value == categoryId) {
      clearSearch();
    } else {
      searchSelectedCategory.value = categoryId;
      if (categoryName != null) {
        searchController.text = categoryName;
        searchText.value = categoryName;
      }
      searchProducts('', category: categoryId);
    }

  }

  /// Searches within a category and populates the search bar
  void searchByCategory(int? categoryId, String categoryName) {
    searchSelectedCategory.value = categoryId;
    searchController.text = categoryName;
    searchText.value = categoryName;
    searchProducts('', category: categoryId);
  }

  /// Resets search state and input
  void clearSearch() {
    _searchTimer?.cancel();
    searchController.clear();
    searchText.value = '';
    searchSelectedCategory.value = null;
    searchResults.clear();
    searchErrorMessage.value = '';
    isSearching.value = false;
  }

  /// Alias for backward compatibility
  void searchProduct({
    required String name,
    double? minPrice,
    double? maxPrice,
    int? category,
    int perPage = 20,
  }) {
    searchProducts(
      name,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      perPage: perPage,
    );
  }

  CategoryModel? get activeRootCategory {
    final selId = selectedCategory.value;
    if (selId == null) return null;
    return categories.firstWhereOrNull(
      (c) => c.id == selId || c.children.any((child) => child.id == selId),
    );
  }

  void setCategory(int? category) {
    selectedCategory.value = category;
    if (category != null) {
      CategoryModel? foundCat = categories.firstWhereOrNull((c) => c.id == category);
      if (foundCat == null) {
        for (final parent in categories) {
          final child = parent.children.firstWhereOrNull((c) => c.id == category);
          if (child != null) {
            foundCat = child;
            break;
          }
        }
      }

      if (foundCat != null && foundCat.products.isNotEmpty) {
        products.assignAll(foundCat.products);
      }
    }
    fetchProducts();
  }

  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;

    fetchProducts();
  }

  void setFeatured(bool value) {
    featuredOnly.value = value;
    fetchProducts();
  }

  void setInStock(bool value) {
    inStockOnly.value = value;
    fetchProducts();
  }

  void setSort(String value) {
    selectedSort.value = value;
    fetchProducts();
  }

  void clearFilters() {
    selectedCategory.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    featuredOnly.value = false;
    inStockOnly.value = true;
    selectedSort.value = '-created_at';
    fetchProducts();
  }
}
