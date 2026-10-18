import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../data/models/product.model.dart';
import '../../../data/models/wishlist.model.dart';
import '../../../data/repository/wishlist_repository.dart';
import '../../cart/controllers/cart_controller.dart';

class WishlistController extends GetxController {
  final WishlistRepository? _repo;

  WishlistController([this._repo]);

  // Reactive state
  final wishlistItems = <WishlistItem>[].obs;
  final meta = Rxn<WishlistMeta>();
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final errorMessage = ''.obs;

  StorageService? get _storage =>
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;

  WishlistRepository? get _effectiveRepo =>
      _repo ??
      (Get.isRegistered<WishlistRepository>()
          ? Get.find<WishlistRepository>()
          : null);

  @override
  void onInit() {
    super.onInit();

    // 1. Load cached items for instant offline/startup display
    _loadFromLocalStorage();

    // 2. Sync with backend API
    fetchWishlist(showLoading: wishlistItems.isEmpty);
  }

  void _loadFromLocalStorage() {
    final storage = _storage;
    if (storage == null) return;
    try {
      final rawList = storage.getWishlistRaw();
      if (rawList.isNotEmpty) {
        final cached = rawList
            .map(
              (item) => WishlistItem.fromJson(
                jsonDecode(item) as Map<String, dynamic>,
              ),
            )
            .toList();
        wishlistItems.assignAll(cached);
      }
    } catch (e) {
      debugPrint('[WishlistController] Error loading from local storage: $e');
    }
  }

  void _saveToLocalStorage() {
    final storage = _storage;
    if (storage == null) return;
    try {
      final rawList = wishlistItems
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      storage.saveWishlistRaw(rawList);
    } catch (e) {
      debugPrint('[WishlistController] Error saving to local storage: $e');
    }
  }

  /// Fetch wishlist data from API and sync with local items
  Future<void> fetchWishlist({bool showLoading = true}) async {
    final repo = _effectiveRepo;
    if (repo == null) return;

    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';

      final res = await repo.getWishlist(page: 1);
      meta.value = res.meta;

      // Only overwrite if backend returned data
      if (res.data.isNotEmpty) {
        wishlistItems.assignAll(res.data);
        _saveToLocalStorage();
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['message'] ?? 'Failed to load wishlist';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// Load more items for pagination
  Future<void> loadMoreWishlist() async {
    final repo = _effectiveRepo;
    if (repo == null || isMoreLoading.value) return;

    final currentMeta = meta.value;
    if (currentMeta == null ||
        currentMeta.currentPage >= currentMeta.lastPage) {
      return;
    }

    try {
      isMoreLoading.value = true;
      final nextPage = currentMeta.currentPage + 1;
      final res = await repo.getWishlist(page: nextPage);
      meta.value = res.meta;
      wishlistItems.addAll(res.data);
      // _saveToLocalStorage();
    } catch (e) {
      debugPrint('Error loading more wishlist items: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Check if a product is in the wishlist
  bool isItemInWishlist(int productId) {
    return wishlistItems.any((item) => item.productId == productId);
  }

  /// Toggle item in wishlist (Add / Remove)
  Future<void> toggleWishlist(ProductRes product, {String size = ''}) async {
    final repo = _effectiveRepo;
    final existingIndex = wishlistItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      final removedItem = wishlistItems.removeAt(existingIndex);
      _saveToLocalStorage();

      if (repo != null) {
        try {
          await repo.removeFromWishlist(removedItem.id);
        } catch (e) {
          debugPrint('[WishlistController] removeFromWishlist error: $e');
          // Revert optimistic removal
          wishlistItems.insert(existingIndex, removedItem);
          _saveToLocalStorage();
        }
      } else {
        debugPrint(
          '[WishlistController] repo is null – removeFromWishlist skipped',
        );
      }
    } else {
      final newItem = WishlistItem.fromProduct(product, size: size);
      wishlistItems.insert(0, newItem);
      _saveToLocalStorage();

      if (repo != null) {
        try {
          final res = await repo.toggleWishlist(product.id, size: size);
          debugPrint('[WishlistController] toggleWishlist response: $res');
          if (res != null && res is Map) {
            final serverId = res['data']?['id'] ?? res['id'];
            if (serverId != null && serverId is int) {
              final idx = wishlistItems.indexWhere(
                (it) => it.productId == product.id,
              );
              if (idx >= 0) {
                wishlistItems[idx] = wishlistItems[idx].copyWith(id: serverId);
                _saveToLocalStorage();
              }
            }
          }
        } catch (e) {
          debugPrint('[WishlistController] addToWishlist error: $e');
          // Revert optimistic insert
          wishlistItems.removeWhere((it) => it.productId == product.id);
          _saveToLocalStorage();
        }
      } else {
        debugPrint(
          '[WishlistController] repo is null – addToWishlist skipped, item only saved locally',
        );
      }
    }
  }

  /// Remove item explicitly by ID
  Future<void> removeItem(int id) async {
    final repo = _effectiveRepo;
    final index = wishlistItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = wishlistItems.removeAt(index);
      _saveToLocalStorage();

      if (repo != null) {
        try {
          debugPrint('[WishlistController] removeItem: item.id=${item.id}, item.productId=${item.productId}, item.name=${item.name}');
          await repo.removeFromWishlist(item.productId);
        } catch (e) {
          debugPrint('[WishlistController] removeFromWishlist error: $e');
          // Revert optimistic removal
          wishlistItems.insert(index, item);
          _saveToLocalStorage();
        }
      }
    }
  }

  /// Clear entire wishlist
  void clearWishlist() {
    wishlistItems.clear();
    _saveToLocalStorage();
  }

  /// Move item to Cart
  void moveToCart(WishlistItem item) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().addItem(item.productId, product: item.product);
    }
    Get.snackbar(
      'Added to Cart',
      '${item.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
