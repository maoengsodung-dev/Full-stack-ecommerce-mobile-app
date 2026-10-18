import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/product.model.dart';
import '../../../app/data/models/wishlist.model.dart';
import '../../../app/data/repository/wishlist_repository.dart';
import '../../../app/core/providers/storage_providers.dart';
import '../../cart/presentation/providers/cart_provider.dart';

class WishlistState {
  final AsyncValue<List<WishlistItem>> items;
  final WishlistMeta? meta;
  final bool isMoreLoading;

  const WishlistState({
    this.items = const AsyncValue.loading(),
    this.meta,
    this.isMoreLoading = false,
  });

  List<WishlistItem> get itemList => items.valueOrNull ?? [];

  bool isItemInWishlist(int productId) {
    return itemList.any((item) => item.productId == productId);
  }

  WishlistState copyWith({
    AsyncValue<List<WishlistItem>>? items,
    WishlistMeta? meta,
    bool? isMoreLoading,
  }) {
    return WishlistState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
    );
  }
}

class WishlistNotifier extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    final cached = _loadFromStorage();
    if (cached.isNotEmpty) {
      Future.microtask(() => fetchWishlist(showLoading: false));
      return WishlistState(items: AsyncValue.data(cached));
    }
    Future.microtask(() => fetchWishlist(showLoading: true));
    return const WishlistState();
  }

  List<WishlistItem> _loadFromStorage() {
    try {
      final storage = ref.read(storageServiceProvider);
      final rawList = storage.getWishlistRaw();
      if (rawList.isNotEmpty) {
        return rawList
            .map(
              (item) => WishlistItem.fromJson(
                jsonDecode(item) as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [];
  }

  void _saveToStorage(List<WishlistItem> list) {
    try {
      final storage = ref.read(storageServiceProvider);
      final rawList = list.map((item) => jsonEncode(item.toJson())).toList();
      storage.saveWishlistRaw(rawList);
    } catch (_) {}
  }

  Future<void> fetchWishlist({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(items: const AsyncValue.loading());
    }
    try {
      final repo = ref.read(wishlistRepositoryProvider);
      final res = await repo.getWishlist(page: 1);
      final data = res.data;
      state = state.copyWith(
        items: AsyncValue.data(data),
        meta: res.meta,
      );
      _saveToStorage(data);
    } catch (e, st) {
      if (state.items.valueOrNull == null) {
        final cached = _loadFromStorage();
        state = state.copyWith(items: AsyncValue.data(cached));
      }
    }
  }

  Future<void> toggleWishlist(ProductRes product, {String size = ''}) async {
    final currentList = [...state.itemList];
    final existingIndex =
        currentList.indexWhere((item) => item.productId == product.id);

    final repo = ref.read(wishlistRepositoryProvider);

    if (existingIndex >= 0) {
      final removed = currentList.removeAt(existingIndex);
      state = state.copyWith(items: AsyncValue.data(currentList));
      _saveToStorage(currentList);
      try {
        await repo.removeFromWishlist(removed.id);
      } catch (_) {}
    } else {
      final newItem = WishlistItem.fromProduct(product, size: size);
      currentList.insert(0, newItem);
      state = state.copyWith(items: AsyncValue.data(currentList));
      _saveToStorage(currentList);
      try {
        final res = await repo.toggleWishlist(product.id, size: size);
        if (res != null && res is Map) {
          final serverId = res['data']?['id'] ?? res['id'];
          if (serverId is int) {
            final idx =
                currentList.indexWhere((it) => it.productId == product.id);
            if (idx >= 0) {
              currentList[idx] = currentList[idx].copyWith(id: serverId);
              state = state.copyWith(items: AsyncValue.data(currentList));
              _saveToStorage(currentList);
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<void> removeItem(int id) async {
    final currentList = [...state.itemList];
    final index = currentList.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = currentList.removeAt(index);
      state = state.copyWith(items: AsyncValue.data(currentList));
      _saveToStorage(currentList);

      try {
        final repo = ref.read(wishlistRepositoryProvider);
        await repo.removeFromWishlist(item.productId);
      } catch (_) {}
    }
  }

  void clearWishlist() {
    state = state.copyWith(items: const AsyncValue.data([]));
    _saveToStorage([]);
  }

  void moveToCart(WishlistItem item) {
    ref.read(cartNotifierProvider.notifier).addItem(
          item.productId,
          product: item.product,
        );
  }
}

final wishlistNotifierProvider =
    NotifierProvider<WishlistNotifier, WishlistState>(WishlistNotifier.new);
