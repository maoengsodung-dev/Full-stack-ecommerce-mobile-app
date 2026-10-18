import '../models/category.model.dart';
import '../providers/category_provider.dart';

class CategoryRepository {
  final CategoryProvider _provider;

  CategoryRepository(this._provider);

  /// Retrieves the categories tree (including subcategories & nested products)
  Future<List<CategoryModel>> getCategories() async {
    final response = await _provider.getCategories();
    final rawData = response.data;
    final List data;
    if (rawData is List) {
      data = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      data = rawData['data'] as List;
    } else {
      data = [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  /// Retrieves a specific category by its ID or slug
  Future<CategoryModel?> getCategoryById(dynamic idOrSlug) async {
    final response = await _provider.getCategoryById(idOrSlug);
    final rawData = response.data;
    final Map<String, dynamic>? data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : null;

    return data != null ? CategoryModel.fromJson(data) : null;
  }

  /// Utility to flatten a category hierarchy into a flat list
  List<CategoryModel> flattenTree(List<CategoryModel> tree) {
    final List<CategoryModel> flat = [];
    void traverse(List<CategoryModel> list) {
      for (final cat in list) {
        flat.add(cat);
        if (cat.children.isNotEmpty) {
          traverse(cat.children);
        }
      }
    }

    traverse(tree);
    return flat;
  }
}
