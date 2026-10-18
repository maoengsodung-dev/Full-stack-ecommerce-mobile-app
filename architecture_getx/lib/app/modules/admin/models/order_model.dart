class AdminOrderItem {
  final int id;
  final int? productId;
  final String productName;
  final String? productSku;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const AdminOrderItem({
    required this.id,
    this.productId,
    required this.productName,
    this.productSku,
    this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    String name = 'Product';
    String? sku;
    String? img;
    int? pId = json['product_id'] is num
        ? (json['product_id'] as num).toInt()
        : int.tryParse(json['product_id']?.toString() ?? '');

    if (json['product_snapshot'] is Map) {
      name = json['product_snapshot']['name']?.toString() ?? name;
      sku = json['product_snapshot']['sku']?.toString();
      img = json['product_snapshot']['image']?.toString();
    } else if (json['product'] is Map) {
      name = json['product']['name']?.toString() ?? name;
      sku = json['product']['sku']?.toString();
      if (json['product']['primary_image'] is Map) {
        img = json['product']['primary_image']['url']?.toString();
      }
    }

    final qty = json['quantity'] is num
        ? (json['quantity'] as num).toInt()
        : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
    final unitP = double.tryParse((json['unit_price'] ?? json['price'])?.toString() ?? '0') ?? 0.0;
    final total = double.tryParse((json['line_total'] ?? json['subtotal'])?.toString() ?? '0') ?? (unitP * qty);

    return AdminOrderItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: pId,
      productName: name,
      productSku: sku,
      productImageUrl: img,
      quantity: qty,
      unitPrice: unitP,
      lineTotal: total,
    );
  }
}

class AdminOrder {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String? note;
  final String? trackingNumber;
  final String? customerName;
  final String? customerPhone;
  final String? addressLine;
  final List<AdminOrderItem> items;
  final DateTime? createdAt;

  const AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.subtotal,
    this.shippingFee = 0.0,
    required this.total,
    this.note,
    this.trackingNumber,
    this.customerName,
    this.customerPhone,
    this.addressLine,
    this.items = const [],
    this.createdAt,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    String? custName;
    String? custPhone;
    String? addr;

    if (json['shipping_snapshot'] is Map) {
      final s = json['shipping_snapshot'] as Map;
      custName = s['recipient_name']?.toString();
      custPhone = s['phone']?.toString();
      final addr1 = s['address_line_1']?.toString() ?? '';
      final prov = s['province']?.toString() ?? '';
      addr = [addr1, prov].where((e) => e.isNotEmpty).join(', ');
    } else if (json['user'] is Map) {
      custName = json['user']['name']?.toString();
      custPhone = json['user']['phone']?.toString();
    } else if (json['address'] is Map) {
      final a = json['address'] as Map;
      custName = a['recipient_name']?.toString() ?? a['name']?.toString();
      custPhone = a['phone_number']?.toString() ?? a['phone']?.toString();
      addr = a['address_line_1']?.toString() ?? a['address']?.toString();
    }

    List<AdminOrderItem> itemList = [];
    if (json['items'] is List) {
      itemList = (json['items'] as List)
          .map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }

    return AdminOrder(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: (json['order_number'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
      paymentMethod: json['payment_method']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      shippingFee: double.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      note: json['note']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      customerName: custName,
      customerPhone: custPhone,
      addressLine: addr,
      items: itemList,
      createdAt: created,
    );
  }
}
