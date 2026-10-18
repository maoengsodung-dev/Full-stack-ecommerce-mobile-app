import 'package:architecture_getx/app/core/utils/media_url_resolver.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'product', 'promo', 'order', 'system', 'location', 'bell'
  final Map<String, dynamic>? data;
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.time,
    this.isRead = false,
  });

  String? get productId => data?['product_id']?.toString() ?? (type == 'product' ? (data?['id']?.toString()) : null);
  String? get productSlug => data?['slug']?.toString();
  String? get bannerId => data?['banner_id']?.toString() ?? (type == 'promo' ? (data?['id']?.toString()) : null);
  
  String? get imageUrl {
    final raw = data?['image']?.toString();
    if (raw == null || raw.isEmpty) return null;
    return MediaUrlResolver.resolve(raw);
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is String) {
        return DateTime.tryParse(raw) ?? DateTime.now();
      }
      return DateTime.now();
    }

    // Determine type from root or nested data
    final nestedData = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null;
    String resolvedType = json['type']?.toString() ?? '';
    if (resolvedType.isEmpty && nestedData != null) {
      resolvedType = nestedData['type']?.toString() ?? '';
    }
    if (resolvedType.isEmpty) {
      final event = json['event']?.toString() ?? nestedData?['event']?.toString();
      if (event == 'new_product') {
        resolvedType = 'product';
      } else if (event == 'new_promotion') resolvedType = 'promo';
      else resolvedType = 'system';
    }

    return NotificationModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: resolvedType,
      data: nestedData,
      time: parseTime(json['time'] ?? json['created_at']),
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'data': data,
    'time': time.toIso8601String(),
    'is_read': isRead,
  };
}
