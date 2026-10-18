import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/network_providers.dart';
import '../models/category.model.dart';
import '../models/product.model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient);
});

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<ProductRes>> getProduct({
    bool? featured,
    double? maxPrice,
    double? minPrice,
    int? category,
    String? search,
    int perPage = 20,
    bool inStock = true,
  }) async {
    return await _apiClient.getProducts(
      perPage: perPage,
      search: search,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      featured: featured,
      inStock: inStock,
    );
  }

  Future<ProductRes> getProductBySlug(String slug) async {
    final response = await _apiClient.get('/products/$slug');
    final rawData = response.data;
    final data = rawData is Map ? (rawData['data'] ?? rawData) : rawData;
    return ProductRes.fromJson(data as Map<String, dynamic>);
  }

  Future<ProductRes> getProductById(dynamic idOrSlug) async {
    try {
      final response = await _apiClient.get('/products/$idOrSlug');
      final rawData = response.data;
      final data = rawData is Map ? (rawData['data'] ?? rawData) : rawData;
      return ProductRes.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final parsedId = int.tryParse(idOrSlug.toString());
      if (e.response?.statusCode == 404 && parsedId != null) {
        final products = await getProduct(perPage: 100);
        final matched = products.where((p) => p.id == parsedId).firstOrNull;
        if (matched != null) {
          if (matched.slug.isNotEmpty) {
            return await getProductBySlug(matched.slug);
          }
          return matched;
        }
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    return await _apiClient.getCategories();
  }
}
