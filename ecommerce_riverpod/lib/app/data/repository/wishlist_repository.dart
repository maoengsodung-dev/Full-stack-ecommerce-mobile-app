import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist.model.dart';
import '../providers/wishlist_provider.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final provider = ref.watch(wishlistDataProvider);
  return WishlistRepository(provider);
});

class WishlistRepository {
  final WishlistProvider _provider;

  WishlistRepository(this._provider);

  Future<WishlistRes> getWishlist({int page = 1, int perPage = 20}) async {
    final response = await _provider.getWishlist(page: page, perPage: perPage);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return WishlistRes.fromJson(data);
    } else if (data is List) {
      return WishlistRes(
        success: true,
        message: '',
        data: data.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    return WishlistRes.empty();
  }

  Future<dynamic> addToWishlist(int productId, {String size = 'M'}) async {
    final response = await _provider.addToWishlist(productId, size: size);
    return response.data;
  }

  Future<void> removeFromWishlist(int id) async {
    await _provider.removeFromWishlist(id);
  }

  Future<dynamic> toggleWishlist(int productId, {String size = 'M'}) async {
    final response = await _provider.toggleWishlist(productId);
    return response.data;
  }
}
