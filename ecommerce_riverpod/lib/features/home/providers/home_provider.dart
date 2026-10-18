import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/banner.model.dart';
import '../../../app/data/models/category.model.dart';
import '../../../app/data/models/product.model.dart';
import '../../../app/data/repository/banner_repository.dart';
import '../../../app/data/repository/category_repository.dart';
import '../../../app/data/repository/product_repository.dart';
import '../../../app/core/providers/storage_providers.dart';

class HomeState {
  final AsyncValue<List<ProductRes>> products;
  final AsyncValue<List<CategoryModel>> categories;
  final AsyncValue<List<BannerModel>> banners;
  final int? selectedCategory;
  final String searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final bool featuredOnly;
  final bool inStockOnly;
  final List<String> recentSearches;

  const HomeState({
    this.products = const AsyncValue.loading(),
    this.categories = const AsyncValue.loading(),
    this.banners = const AsyncValue.loading(),
    this.selectedCategory,
    this.searchQuery = '',
    this.minPrice,
    this.maxPrice,
    this.featuredOnly = false,
    this.inStockOnly = true,
    this.recentSearches = const [],
  });

  HomeState copyWith({
    AsyncValue<List<ProductRes>>? products,
    AsyncValue<List<CategoryModel>>? categories,
    AsyncValue<List<BannerModel>>? banners,
    int? Function()? selectedCategory,
    String? searchQuery,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    bool? featuredOnly,
    bool? inStockOnly,
    List<String>? recentSearches,
  }) {
    return HomeState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      banners: banners ?? this.banners,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  Timer? _searchDebounce;

  @override
  HomeState build() {
    final storage = ref.watch(storageServiceProvider);
    final recents = storage.getRecentSearches();

    Future.microtask(() {
      fetchBanners();
      fetchCategories();
      fetchProducts();
    });

    return HomeState(recentSearches: recents);
  }

  Future<void> fetchBanners() async {
    state = state.copyWith(banners: const AsyncValue.loading());
    try {
      final repo = ref.read(bannerRepositoryProvider);
      final list = await repo.getBanners();
      state = state.copyWith(banners: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(banners: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(categories: const AsyncValue.loading());
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final list = await repo.getCategories();
      state = state.copyWith(categories: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(categories: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(products: const AsyncValue.loading());
    try {
      final repo = ref.read(productRepositoryProvider);
      final list = await repo.getProduct(
        category: state.selectedCategory,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        featured: state.featuredOnly ? true : null,
        inStock: state.inStockOnly,
      );
      state = state.copyWith(products: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(products: AsyncValue.error(e, st));
    }
  }

  void selectCategory(int? categoryId) {
    if (state.selectedCategory == categoryId) {
      state = state.copyWith(selectedCategory: () => null);
    } else {
      state = state.copyWith(selectedCategory: () => categoryId);
    }
    fetchProducts();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isNotEmpty) {
        addRecentSearch(query.trim());
      }
      fetchProducts();
    });
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    fetchProducts();
  }

  void applyFilters({
    double? min,
    double? max,
    bool? featured,
    bool? inStock,
  }) {
    state = state.copyWith(
      minPrice: () => min,
      maxPrice: () => max,
      featuredOnly: featured,
      inStockOnly: inStock,
    );
    fetchProducts();
  }

  void resetFilters() {
    state = state.copyWith(
      minPrice: () => null,
      maxPrice: () => null,
      featuredOnly: false,
      inStockOnly: true,
      selectedCategory: () => null,
    );
    fetchProducts();
  }

  void addRecentSearch(String term) {
    final storage = ref.read(storageServiceProvider);
    final updated = [term, ...state.recentSearches.where((s) => s != term)]
        .take(10)
        .toList();
    storage.saveRecentSearches(updated);
    state = state.copyWith(recentSearches: updated);
  }

  void clearRecentSearches() {
    final storage = ref.read(storageServiceProvider);
    storage.clearRecentSearches();
    state = state.copyWith(recentSearches: const []);
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchBanners(),
      fetchCategories(),
      fetchProducts(),
    ]);
  }
}

final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
