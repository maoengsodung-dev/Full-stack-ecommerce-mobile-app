import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';
import 'package:dio/dio.dart';

final categoryDataProvider = Provider<CategoryProvider>((ref) {
  return CategoryProvider(ref.watch(apiClientProvider));
});

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
