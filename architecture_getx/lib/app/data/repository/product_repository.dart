import 'package:architecture_getx/app/core/network/api_client.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';

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
    final response = await _apiClient.get('/products/$idOrSlug');
    final rawData = response.data;
    final data = rawData is Map ? (rawData['data'] ?? rawData) : rawData;
    return ProductRes.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> getCategories() async {
    return await _apiClient.getCategories();
  }
}
