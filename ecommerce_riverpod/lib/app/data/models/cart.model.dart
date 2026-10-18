import 'product.model.dart';

class CartItem {
  final int id;
  final ProductRes product;
  final int quantity;
  final double price;
  final int? productVariantId;
  final ProductVariantModel? variant;
  final double? lineTotal;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.productVariantId,
    this.variant,
    this.lineTotal,
  });

  double get total => lineTotal ?? (price * quantity);
  double get subtotal => total;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'] is Map ? Map<String, dynamic>.from(json['product']) : <String, dynamic>{};
    final product = ProductRes.fromJson(rawProduct);

    final rawPrice = double.tryParse((json['unit_price'] ?? json['price'])?.toString() ?? '0') ?? 0.0;
    final resolvedPrice = rawPrice > 0
        ? rawPrice
        : (product.effectivePrice > 0 ? product.effectivePrice : product.price);

    final rawVariant = json['variant'] is Map ? Map<String, dynamic>.from(json['variant']) : null;
    final variant = rawVariant != null ? ProductVariantModel.fromJson(rawVariant) : null;

    final parsedLineTotal = json['line_total'] != null
        ? double.tryParse(json['line_total'].toString())
        : null;

    return CartItem(
      id: json['id'] ?? 0,
      product: product,
      quantity: json['quantity'] ?? 1,
      price: resolvedPrice,
      productVariantId: json['product_variant_id'] as int?,
      variant: variant,
      lineTotal: parsedLineTotal,
    );
  }
}

class CartRes {
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final int itemsCount;
  final String? couponCode;

  CartRes({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    this.discount = 0.0,
    required this.total,
    required this.itemsCount,
    this.couponCode,
  });

  factory CartRes.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final items = rawItems
        .whereType<Map>()
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return CartRes(
      items: items,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      shippingFee: double.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      itemsCount: json['items_count'] ?? items.length,
      couponCode: json['coupon_code']?.toString(),
    );
  }

  static CartRes empty() => CartRes(
    items: [],
    subtotal: 0,
    shippingFee: 0,
    discount: 0,
    total: 0,
    itemsCount: 0,
  );
}
