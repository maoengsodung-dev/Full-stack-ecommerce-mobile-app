
import '../../core/utils/media_url_resolver.dart';
import 'product.model.dart';

class WishlistMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final String? path;
  final int perPage;
  final int? to;
  final int total;

  WishlistMeta({
    this.currentPage = 1,
    this.from,
    this.lastPage = 1,
    this.path,
    this.perPage = 20,
    this.to,
    this.total = 0,
  });

  factory WishlistMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WishlistMeta();
    return WishlistMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      path: json['path'],
      perPage: json['per_page'] ?? 20,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'from': from,
        'last_page': lastPage,
        'path': path,
        'per_page': perPage,
        'to': to,
        'total': total,
      };
}

class WishlistRes {
  final bool success;
  final String message;
  final List<WishlistItem> data;
  final WishlistMeta? meta;

  WishlistRes({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory WishlistRes.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List? ?? [];
    final items = rawData
        .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return WishlistRes(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: items,
      meta: json['meta'] != null
          ? WishlistMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  static WishlistRes empty() => WishlistRes(
        success: true,
        message: '',
        data: [],
        meta: WishlistMeta(),
      );
}

class WishlistItem {
  final int id;
  final int productId;
  final String name;
  final String slug;
  final String imageUrl;
  final String size;
  final double rating;
  final int reviewsCount;
  final double price;
  final double? originalPrice;
  final String? subtitle;
  final ProductRes? product;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    this.slug = '',
    required this.imageUrl,
    required this.size,
    required this.rating,
    this.reviewsCount = 0,
    required this.price,
    this.originalPrice,
    this.subtitle,
    this.product,
  });

  factory WishlistItem.fromProduct(ProductRes product, {String size = 'M'}) {
    return WishlistItem(
      id: product.id,
      productId: product.id,
      name: product.name,
      slug: product.slug,
      imageUrl: product.primaryImage?.url ?? '',
      size: size,
      rating: product.rating > 0 ? product.rating : 4.8,
      reviewsCount: product.reviewsCount > 0 ? product.reviewsCount : 120,
      price: product.effectivePrice > 0 ? product.effectivePrice : product.price,
      originalPrice: product.onSale ? product.price : null,
      subtitle: product.category?.name,
      product: product,
    );
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // If json contains nested product object
    ProductRes? parsedProduct;
    if (json['product'] != null && json['product'] is Map) {
      parsedProduct =
          ProductRes.fromJson(json['product'] as Map<String, dynamic>);
    }

    final int id = json['id'] ?? (parsedProduct?.id ?? 0);
    final int productId = json['product_id'] ?? (parsedProduct?.id ?? id);

    // Resolve name
    final String name = json['name'] ??
        json['product_name'] ??
        (parsedProduct?.name ?? '');

    // Resolve slug
    final String slug = json['slug']?.toString() ??
        json['product_slug']?.toString() ??
        (parsedProduct?.slug ?? '');

    // Resolve image
    String imageUrl = '';
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      imageUrl = json['image_url'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = json['image'].toString();
    } else if (json['primary_image'] != null && json['primary_image'] is Map) {
      imageUrl = json['primary_image']['url']?.toString() ?? '';
    } else if (parsedProduct?.primaryImage?.url != null) {
      imageUrl = parsedProduct!.primaryImage!.url;
    }
    imageUrl = MediaUrlResolver.resolve(imageUrl);

    // Resolve size
    final String size = json['size'] ?? 'M';

    // Resolve rating
    final double rating = double.tryParse(
          json['rating']?.toString() ??
              parsedProduct?.rating.toString() ??
              '4.8',
        ) ??
        4.8;

    // Resolve reviews count
    final int reviewsCount = json['reviews_count'] ??
        parsedProduct?.reviewsCount ??
        (json['rating'] != null ? 120 : 0);

    // Resolve price
    final double rawPrice = double.tryParse(
          json['effective_price']?.toString() ??
              json['price']?.toString() ??
              parsedProduct?.effectivePrice.toString() ??
              parsedProduct?.price.toString() ??
              '0',
        ) ??
        0.0;

    // Resolve original / sale price
    final double? originalPrice = json['original_price'] != null
        ? double.tryParse(json['original_price'].toString())
        : (parsedProduct?.onSale == true ? parsedProduct?.price : null);

    // Resolve subtitle / category / location
    final String? subtitle = json['subtitle'] ??
        json['location'] ??
        json['category_name'] ??
        parsedProduct?.category?.name;

    return WishlistItem(
      id: id,
      productId: productId,
      name: name,
      slug: slug,
      imageUrl: imageUrl,
      size: size,
      rating: rating,
      reviewsCount: reviewsCount,
      price: rawPrice,
      originalPrice: originalPrice,
      subtitle: subtitle,
      product: parsedProduct,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'slug': slug.isNotEmpty ? slug : (product?.slug ?? ''),
        'image_url': imageUrl,
        'size': size,
        'rating': rating,
        'reviews_count': reviewsCount,
        'price': price,
        'original_price': originalPrice,
        'subtitle': subtitle,
        if (product != null) 'product': product!.toJson(),
      };

  WishlistItem copyWith({
    int? id,
    int? productId,
    String? name,
    String? slug,
    String? imageUrl,
    String? size,
    double? rating,
    int? reviewsCount,
    double? price,
    double? originalPrice,
    String? subtitle,
    ProductRes? product,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      subtitle: subtitle ?? this.subtitle,
      product: product ?? this.product,
    );
  }

  ProductRes toProduct() {
    if (product != null) return product!;
    return ProductRes(
      id: productId,
      name: name,
      slug: slug.isNotEmpty ? slug : name.toLowerCase().replaceAll(' ', '-'),
      description: '',
      shortDescription: '',
      price: originalPrice ?? price,
      salePrice: originalPrice != null && originalPrice! > price ? price : null,
      effectivePrice: price,
      onSale: originalPrice != null && originalPrice! > price,
      stock: 10,
      status: 'active',
      isFeatured: false,
      rating: rating,
      reviewsCount: reviewsCount,
      soldCount: 0,
      category: subtitle != null
          ? CategoryModel(id: 0, name: subtitle!, slug: '')
          : null,
      primaryImage: imageUrl.isNotEmpty
          ? PrimaryImageModel(id: 0, url: imageUrl, alt: name)
          : null,
    );
  }

  String get categoryName => subtitle ?? product?.category?.name ?? '';
}
