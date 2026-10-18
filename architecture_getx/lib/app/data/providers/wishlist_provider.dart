import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

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
  /// Server adds if not in wishlist, removes if already in wishlist.
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
