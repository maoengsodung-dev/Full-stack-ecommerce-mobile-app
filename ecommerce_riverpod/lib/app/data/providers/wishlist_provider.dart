import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';



final wishlistDataProvider = Provider<WishlistProvider>((ref) {
  return WishlistProvider(ref.watch(apiClientProvider));
});

class WishlistProvider {
  final ApiClient _apiClient;

  WishlistProvider(this._apiClient);

  Future<Response> getWishlist({int page = 1, int perPage = 20}) async {
    return await _apiClient.get(
      kWishlist,
      queryParameters: {'page': page, 'per_page': perPage},
    );
  }

  /// Toggle wishlist: POST /wishlist/{productId}
  Future<Response> toggleWishlist(int productId) async {
    debugPrint('[WishlistProvider] toggleWishlist POST $kWishlist/$productId');
    return await _apiClient.post('$kWishlist/$productId');
  }

  Future<Response> addToWishlist(int productId, {String size = 'M'}) async {
    return await toggleWishlist(productId);
  }

  Future<Response> removeFromWishlist(int productId) async {
    return await toggleWishlist(productId);
  }
}
