import 'package:architecture_getx/app/core/utils/media_url_resolver.dart';
import 'product.model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? image;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final List<ProductRes> products;
  final List<CategoryModel> children;
  final int productsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.image,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.products = const [],
    this.children = const [],
    this.productsCount = 0,
  });

  bool get hasChildren => children.isNotEmpty;
  bool get hasProducts => products.isNotEmpty || productsCount > 0;
  String? get displayImage {
    if (image != null && image!.trim().isNotEmpty) return image;
    if (icon != null && icon!.trim().isNotEmpty) return icon;
    return null;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon'] != null ? MediaUrlResolver.resolve(json['icon']?.toString()) : null,
      image: json['image'] != null ? MediaUrlResolver.resolve(json['image']?.toString()) : null,
      parentId: json['parent_id'] is num
          ? (json['parent_id'] as num).toInt()
          : int.tryParse(json['parent_id']?.toString() ?? ''),
      sortOrder: json['sort_order'] is num ? (json['sort_order'] as num).toInt() : 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      products: (json['products'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => ProductRes.fromJson(e))
              .toList() ??
          const [],
      children: (json['children'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => CategoryModel.fromJson(e))
              .toList() ??
          const [],
      productsCount: json['products_count'] is num
          ? (json['products_count'] as num).toInt()
          : ((json['products'] as List<dynamic>?)?.length ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'image': image,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
      'products': products.map((p) => {
        'id': p.id,
        'name': p.name,
        'slug': p.slug,
        'price': p.price,
      }).toList(),
      'children': children.map((c) => c.toJson()).toList(),
      'products_count': productsCount,
    };
  }
}
