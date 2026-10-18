import 'package:dio/dio.dart';

import '../../core/constants/constant.dart';
import '../../core/network/api_client.dart';

class CategoryProvider {
  final ApiClient _apiClient;

  CategoryProvider(this._apiClient);

  /// Fetches the categories tree from the backend API (`GET /categories`)
  Future<Response> getCategories() async {
    return await _apiClient.get(kCategories);
  }

  /// Fetches a single category by ID or slug (`GET /categories/:idOrSlug`)
  Future<Response> getCategoryById(dynamic idOrSlug) async {
    return await _apiClient.get('$kCategories/$idOrSlug');
  }
}
