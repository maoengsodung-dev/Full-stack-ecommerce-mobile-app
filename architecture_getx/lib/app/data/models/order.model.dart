import 'package:intl/intl.dart';
import 'package:architecture_getx/app/core/utils/media_url_resolver.dart';
import 'address.model.dart';
import 'product.model.dart';

class OrderItem {
  final int id;
  final ProductRes product;
  final int quantity;
  final double price;
  final int? productVariantId;
  final double? lineTotal;
  final String? sku;
  final String? size;
  final String? color;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    this.productVariantId,
    this.lineTotal,
    this.sku,
    this.size,
    this.color,
  });

  double get subtotal => lineTotal ?? (price * quantity);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    ProductRes parsedProduct;
    String? extractedSku;
    String? extractedSize;
    String? extractedColor;

    if (json['product_snapshot'] is Map) {
      final snap = Map<String, dynamic>.from(json['product_snapshot']);
      extractedSku = snap['sku']?.toString();
      extractedSize = snap['size']?.toString();
      extractedColor = snap['color']?.toString();
    }
    if (json['variant'] is Map) {
      final v = Map<String, dynamic>.from(json['variant']);
      extractedSku ??= v['sku']?.toString();
      extractedSize ??= v['size']?.toString();
      extractedColor ??= v['color']?.toString();
    }

    if (json['product'] is Map) {
      parsedProduct = ProductRes.fromJson(Map<String, dynamic>.from(json['product']));
      if ((parsedProduct.primaryImage == null || parsedProduct.primaryImage!.url.isEmpty) && json['product_snapshot'] is Map) {
        final snap = Map<String, dynamic>.from(json['product_snapshot']);
        final imgUrl = MediaUrlResolver.resolve(snap['image']?.toString());
        if (imgUrl.isNotEmpty) {
          parsedProduct = ProductRes(
            id: parsedProduct.id,
            name: parsedProduct.name,
            slug: parsedProduct.slug,
            description: parsedProduct.description,
            shortDescription: parsedProduct.shortDescription,
            price: parsedProduct.price,
            effectivePrice: parsedProduct.effectivePrice,
            onSale: parsedProduct.onSale,
            stock: parsedProduct.stock,
            status: parsedProduct.status,
            isFeatured: parsedProduct.isFeatured,
            rating: parsedProduct.rating,
            reviewsCount: parsedProduct.reviewsCount,
            soldCount: parsedProduct.soldCount,
            category: parsedProduct.category,
            primaryImage: PrimaryImageModel(id: 0, url: imgUrl, alt: parsedProduct.name),
            images: parsedProduct.images,
            variants: parsedProduct.variants,
            attributes: parsedProduct.attributes,
            createdAt: parsedProduct.createdAt,
          );
        }
      }
    } else if (json['product_snapshot'] is Map) {
      final snap = Map<String, dynamic>.from(json['product_snapshot']);
      final imgUrl = MediaUrlResolver.resolve(snap['image']?.toString());

      parsedProduct = ProductRes(
        id: json['product_id'] ?? 0,
        name: snap['name']?.toString() ?? '',
        slug: snap['slug']?.toString() ?? '',
        description: '',
        shortDescription: '',
        price: double.tryParse((json['unit_price'] ?? json['price'])?.toString() ?? '0') ?? 0,
        effectivePrice: double.tryParse((json['unit_price'] ?? json['price'])?.toString() ?? '0') ?? 0,
        onSale: false,
        stock: 0,
        status: 'active',
        isFeatured: false,
        rating: 5.0,
        reviewsCount: 0,
        soldCount: 0,
        primaryImage: imgUrl.isNotEmpty
            ? PrimaryImageModel(id: 0, url: imgUrl, alt: snap['name']?.toString() ?? '')
            : null,
      );
    } else {
      parsedProduct = ProductRes.fromJson({});
    }

    final rawPrice = double.tryParse((json['unit_price'] ?? json['price'])?.toString() ?? '0') ?? 0.0;
    return OrderItem(
      id: json['id'] ?? 0,
      product: parsedProduct,
      quantity: json['quantity'] ?? 1,
      price: rawPrice > 0 ? rawPrice : parsedProduct.price,
      productVariantId: json['product_variant_id'] as int?,
      lineTotal: json['line_total'] != null ? double.tryParse(json['line_total'].toString()) : null,
      sku: extractedSku,
      size: extractedSize,
      color: extractedColor,
    );
  }
}

class OrderRes {
  final int id;
  final String orderNumber;
  final String status;
  final String? statusLabel;
  final String paymentStatus;
  final String paymentMethod;
  final String currency;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final List<OrderItem> items;
  final AddressModel? address;
  final String? notes;
  final String? trackingNumber;
  final DateTime? createdAt;
  final Map<String, dynamic>? payment;

  OrderRes({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.statusLabel,
    required this.paymentStatus,
    this.paymentMethod = 'payway',
    this.currency = 'USD',
    required this.subtotal,
    required this.shippingFee,
    this.discount = 0.0,
    required this.total,
    required this.items,
    this.address,
    this.notes,
    this.trackingNumber,
    this.createdAt,
    this.payment,
  });

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString());
  }

  factory OrderRes.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['order'] is Map<String, dynamic>
        ? json['order'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    final rawItems = (data['items'] ?? json['items']) as List? ?? [];

    AddressModel? parsedAddress;
    if (data['address'] != null && data['address'] is Map) {
      parsedAddress = AddressModel.fromJson(Map<String, dynamic>.from(data['address']));
    } else if (data['shipping_snapshot'] != null && data['shipping_snapshot'] is Map) {
      parsedAddress = AddressModel.fromJson(Map<String, dynamic>.from(data['shipping_snapshot']));
    } else if (json['address'] != null && json['address'] is Map) {
      parsedAddress = AddressModel.fromJson(Map<String, dynamic>.from(json['address']));
    }

    return OrderRes(
      id: data['id'] ?? json['id'] ?? 0,
      orderNumber: (data['order_number'] ?? json['order_number'] ?? data['id'] ?? json['id'] ?? '').toString(),
      status: (data['status'] ?? json['status'] ?? 'pending').toString(),
      statusLabel: (data['status_label'] ??
              json['status_label'] ??
              data['status_text'] ??
              json['status_text'] ??
              data['badge'] ??
              json['badge'])
          ?.toString(),
      paymentStatus: (data['payment_status'] ?? json['payment_status'] ?? 'pending').toString(),
      paymentMethod: (data['payment_method'] ?? json['payment_method'] ?? 'payway').toString(),
      currency: (data['currency'] ?? json['currency'] ?? 'USD').toString(),
      subtotal: double.tryParse((data['subtotal'] ?? json['subtotal'])?.toString() ?? '0') ?? 0,
      shippingFee: double.tryParse((data['shipping_fee'] ?? json['shipping_fee'])?.toString() ?? '0') ?? 0,
      discount: double.tryParse((data['discount'] ?? json['discount'])?.toString() ?? '0') ?? 0,
      total: double.tryParse((data['total'] ?? json['total'])?.toString() ?? '0') ?? 0,
      items: rawItems
          .whereType<Map>()
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      address: parsedAddress,
      notes: data['note'] ?? data['notes'] ?? json['note'] ?? json['notes'],
      trackingNumber: (data['tracking_number'] ?? json['tracking_number'])?.toString(),
      createdAt: _parseDate(
        data['created_at'] ??
            json['created_at'] ??
            data['order_date'] ??
            json['order_date'] ??
            data['date'] ??
            json['date'],
      ),
      payment: (json['payment'] ?? data['payment'] ?? data['latest_payment']) is Map<String, dynamic>
          ? (json['payment'] ?? data['payment'] ?? data['latest_payment']) as Map<String, dynamic>
          : null,
    );
  }

  /// Formatted date, e.g. "Oct 28, 2026"
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('MMM dd, yyyy').format(createdAt!);
  }

  /// Formatted short date, e.g. "Oct 28"
  String get formattedDateShort {
    if (createdAt == null) return '';
    return DateFormat('MMM dd').format(createdAt!);
  }

  /// Display string for status badge, e.g. "Processing Atelier", "Pending", etc.
  String get statusDisplay {
    if (statusLabel != null && statusLabel!.trim().isNotEmpty) {
      return statusLabel!.trim();
    }
    final s = status.trim().toLowerCase();
    switch (s) {
      case 'processing':
        return 'Processing Atelier';
      case 'pending':
        return 'Pending';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      default:
        if (s.isEmpty) return 'Processing Atelier';
        return s.split(RegExp(r'[_\s]+')).map((w) {
          if (w.isEmpty) return '';
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        }).join(' ');
    }
  }

  OrderRes copyWith({
    int? id,
    String? orderNumber,
    String? status,
    String? statusLabel,
    String? paymentStatus,
    double? subtotal,
    double? shippingFee,
    double? total,
    List<OrderItem>? items,
    AddressModel? address,
    String? notes,
    DateTime? createdAt,
    Map<String, dynamic>? payment,
  }) {
    return OrderRes(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      total: total ?? this.total,
      items: items ?? this.items,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      payment: payment ?? this.payment,
    );
  }
}

