import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class BannerProvider {
  final ApiClient _apiClient;

  BannerProvider(this._apiClient);

  /// Fetches active banners from backend (`GET /banners`)
  Future<Response> getBanners({String? position}) async {
    final query = <String, dynamic>{};
    if (position != null && position.trim().isNotEmpty) {
      query['position'] = position.trim();
    }
    return await _apiClient.get(
      kBanners,
      queryParameters: query.isNotEmpty ? query : null,
    );
  }

  /// Fetches a single banner by ID (`GET /banners/:id`)
  Future<Response> getBannerById(dynamic id) async {
    return await _apiClient.get('$kBanners/$id');
  }
}
