
import '../../../../app/core/utils/media_url_resolver.dart';
import 'variant_model.dart';

class AdminProduct {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final double price;
  final double? salePrice;
  final int stock;
  final String status;
  final bool isFeatured;
  final int? categoryId;
  final String? categoryName;
  final String? primaryImageUrl;
  final List<String> imageUrls;
  final List<AdminVariant> variants;
  final DateTime? createdAt;

  const AdminProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.shortDescription = '',
    required this.price,
    this.salePrice,
    required this.stock,
    this.status = 'active',
    this.isFeatured = false,
    this.categoryId,
    this.categoryName,
    this.primaryImageUrl,
    this.imageUrls = const [],
    this.variants = const [],
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get hasSale => salePrice != null && salePrice! > 0 && salePrice! < price;
  double get effectivePrice => hasSale ? salePrice! : price;

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    String? imgUrl;
    final List<String> allImages = [];

    if (json['primary_image'] is Map) {
      imgUrl = json['primary_image']['url']?.toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = (json['images'] as List).first;
      if (first is Map) imgUrl = first['url']?.toString();
    }

    if (json['images'] is List) {
      for (final it in json['images'] as List) {
        if (it is Map && it['url'] != null) {
          final u = MediaUrlResolver.resolve(it['url'].toString());
          if (u.isNotEmpty && !allImages.contains(u)) allImages.add(u);
        } else if (it is String && it.isNotEmpty) {
          final u = MediaUrlResolver.resolve(it);
          if (u.isNotEmpty && !allImages.contains(u)) allImages.add(u);
        }
      }
    }

    // Resolve URLs safely for emulator & web
    if (imgUrl != null && imgUrl.isNotEmpty) {
      imgUrl = MediaUrlResolver.resolve(imgUrl);
      if (!allImages.contains(imgUrl)) {
        allImages.insert(0, imgUrl);
      }
    }

    String? catName;
    int? catId;
    if (json['category'] is Map) {
      catName = json['category']['name']?.toString();
      catId = json['category']['id'] is num
          ? (json['category']['id'] as num).toInt()
          : int.tryParse(json['category']['id']?.toString() ?? '');
    } else if (json['category_id'] != null) {
      catId = json['category_id'] is num
          ? (json['category_id'] as num).toInt()
          : int.tryParse(json['category_id'].toString());
    }

    List<AdminVariant> vars = [];
    if (json['variants'] is List) {
      vars = (json['variants'] as List)
          .map((e) => AdminVariant.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }

    return AdminProduct(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      salePrice: json['sale_price'] != null
          ? double.tryParse(json['sale_price'].toString())
          : null,
      stock: json['stock'] is num
          ? (json['stock'] as num).toInt()
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'active',
      isFeatured:
          json['is_featured'] == true ||
          json['is_featured'] == 1 ||
          json['is_featured']?.toString() == 'true',
      categoryId: catId,
      categoryName: catName,
      primaryImageUrl: imgUrl,
      imageUrls: allImages,
      variants: vars,
      createdAt: created,
    );
  }

  Map<String, dynamic> toCreatePayload({List<Map<String, dynamic>>? images}) {
    return {
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      if (salePrice != null && salePrice! > 0) 'sale_price': salePrice,
      'stock': stock,
      if (categoryId != null) 'category_id': categoryId,
      'status': status,
      'is_featured': isFeatured,
      if (images != null && images.isNotEmpty)
        'images': images
      else if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty)
        'images': [
          {'url': primaryImageUrl, 'is_primary': true},
        ],
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      if (salePrice != null) 'sale_price': salePrice,
      'stock': stock,
      if (categoryId != null) 'category_id': categoryId,
      'status': status,
      'is_featured': isFeatured,
    };
  }
}
