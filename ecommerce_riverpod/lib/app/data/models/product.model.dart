
import '../../core/utils/media_url_resolver.dart';
import 'category.model.dart';
export 'category.model.dart';

class ProductRes {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;

  final double price;
  final double? salePrice;
  final double effectivePrice;

  final bool onSale;
  final int stock;
  final String status;
  final bool isFeatured;

  final double rating;
  final int reviewsCount;
  final int soldCount;

  final CategoryModel? category;
  final PrimaryImageModel? primaryImage;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;
  final Map<String, dynamic> attributes;

  final DateTime? createdAt;

  ProductRes({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.price,
    this.salePrice,
    required this.effectivePrice,
    required this.onSale,
    required this.stock,
    required this.status,
    required this.isFeatured,
    required this.rating,
    required this.reviewsCount,
    required this.soldCount,
    this.category,
    this.primaryImage,
    this.images = const [],
    this.variants = const [],
    this.attributes = const {},
    this.createdAt,
  });

  factory ProductRes.fromJson(Map<String, dynamic> json) {
    PrimaryImageModel? parsedPrimary;
    if (json['primary_image'] != null && json['primary_image'] is Map) {
      parsedPrimary = PrimaryImageModel.fromJson(
        json['primary_image'] as Map<String, dynamic>,
      );
    }

    final rawImages = json['images'] as List? ?? [];
    final parsedImages = rawImages
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductImageModel.fromJson(e))
        .toList();

    // If primaryImage was not given as an object but images has items, pick primary or first
    if (parsedPrimary == null && parsedImages.isNotEmpty) {
      final found = parsedImages.firstWhere(
        (img) => img.isPrimary,
        orElse: () => parsedImages.first,
      );
      parsedPrimary = PrimaryImageModel(
        id: found.id,
        url: found.url,
        alt: found.alt ?? '',
      );
    } else if (parsedPrimary != null && parsedImages.isEmpty) {
      parsedImages.add(
        ProductImageModel(
          id: parsedPrimary.id,
          url: parsedPrimary.url,
          alt: parsedPrimary.alt,
          isPrimary: true,
        ),
      );
    }

    final rawVariants = json['variants'] as List? ?? [];
    final parsedVariants = rawVariants
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductVariantModel.fromJson(e))
        .toList();

    return ProductRes(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',

      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,

      salePrice: json['sale_price'] == null
          ? null
          : double.tryParse(json['sale_price'].toString()),

      effectivePrice:
          double.tryParse(json['effective_price']?.toString() ?? '0') ??
          (double.tryParse(json['price']?.toString() ?? '0') ?? 0),

      onSale: json['on_sale'] ?? false,
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      isFeatured: json['is_featured'] ?? false,

      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,

      reviewsCount: json['reviews_count'] ?? 0,
      soldCount: json['sold_count'] ?? 0,

      category: json['category'] != null && json['category'] is Map
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,

      primaryImage: parsedPrimary,
      images: parsedImages,
      variants: parsedVariants,
      attributes: json['attributes'] is Map<String, dynamic>
          ? json['attributes'] as Map<String, dynamic>
          : {},

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'short_description': shortDescription,
        'price': price,
        'sale_price': salePrice,
        'effective_price': effectivePrice,
        'on_sale': onSale,
        'stock': stock,
        'status': status,
        'is_featured': isFeatured,
        'rating': rating,
        'reviews_count': reviewsCount,
        'sold_count': soldCount,
        if (category != null) 'category': category!.toJson(),
        if (primaryImage != null)
          'primary_image': {
            'id': primaryImage!.id,
            'url': primaryImage!.url,
            'alt': primaryImage!.alt,
          },
        'images': images
            .map((img) => {
                  'id': img.id,
                  'url': img.url,
                  'alt': img.alt,
                  'sort_order': img.sortOrder,
                  'is_primary': img.isPrimary,
                })
            .toList(),
        'variants': variants
            .map((v) => {
                  'id': v.id,
                  'sku': v.sku,
                  'size': v.size,
                  'color': v.color,
                  'price_offset': v.priceOffset,
                  'effective_price': v.effectivePrice,
                  'stock': v.stock,
                  'is_active': v.isActive,
                })
            .toList(),
        'attributes': attributes,
        'created_at': createdAt?.toIso8601String(),
      };
}


class PrimaryImageModel {
  final int id;
  final String url;
  final String alt;

  PrimaryImageModel({required this.id, required this.url, required this.alt});

  factory PrimaryImageModel.fromJson(Map<String, dynamic> json) {
    return PrimaryImageModel(
      id: json['id'] ?? 0,
      url: MediaUrlResolver.resolve(json['url']?.toString()),
      alt: json['alt'] ?? '',
    );
  }
}

class ProductImageModel {
  final int id;
  final String url;
  final String? alt;
  final int sortOrder;
  final bool isPrimary;

  ProductImageModel({
    required this.id,
    required this.url,
    this.alt,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      url: MediaUrlResolver.resolve(json['url']?.toString()),
      alt: json['alt']?.toString(),
      sortOrder: json['sort_order'] ?? 0,
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}

class ProductVariantModel {
  final int id;
  final String sku;
  final String? size;
  final String? color;
  final double priceOffset;
  final double effectivePrice;
  final int stock;
  final bool isActive;

  ProductVariantModel({
    required this.id,
    required this.sku,
    this.size,
    this.color,
    this.priceOffset = 0,
    this.effectivePrice = 0,
    this.stock = 0,
    this.isActive = true,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      priceOffset: double.tryParse(json['price_offset']?.toString() ?? '0') ?? 0,
      effectivePrice: double.tryParse(json['effective_price']?.toString() ?? '0') ?? 0,
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

