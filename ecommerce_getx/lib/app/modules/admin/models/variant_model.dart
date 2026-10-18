class AdminVariant {
  final int? id;
  final int? productId;
  final String sku;
  final String? size;
  final String? color;
  final double priceOffset;
  final int stock;
  final bool isActive;

  const AdminVariant({
    this.id,
    this.productId,
    required this.sku,
    this.size,
    this.color,
    this.priceOffset = 0.0,
    this.stock = 0,
    this.isActive = true,
  });

  factory AdminVariant.fromJson(Map<String, dynamic> json) {
    return AdminVariant(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      productId: json['product_id'] is num
          ? (json['product_id'] as num).toInt()
          : int.tryParse(json['product_id']?.toString() ?? ''),
      sku: json['sku']?.toString() ?? '',
      size: json['size']?.toString(),
      color: json['color']?.toString(),
      priceOffset: double.tryParse(json['price_offset']?.toString() ?? '0') ?? 0.0,
      stock: json['stock'] is num
          ? (json['stock'] as num).toInt()
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      if (size != null && size!.isNotEmpty) 'size': size,
      if (color != null && color!.isNotEmpty) 'color': color,
      'price_offset': priceOffset,
      'stock': stock,
      'is_active': isActive,
    };
  }
}
