import 'package:architecture_getx/app/core/utils/media_url_resolver.dart';

class BannerModel {
  final int id;
  final String? title;
  final String? subtitle;
  final String image;
  final String resolvedImageUrl;
  final String linkType;
  final String? linkId;
  final String? linkUrl;
  final String position;
  final int sortOrder;
  final bool isActive;
  final String? startAt;
  final String? endAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    this.title,
    this.subtitle,
    required this.image,
    String? resolvedImageUrl,
    this.linkType = 'none',
    this.linkId,
    this.linkUrl,
    this.position = 'home_slider',
    this.sortOrder = 0,
    this.isActive = true,
    this.startAt,
    this.endAt,
    this.createdAt,
    this.updatedAt,
  }) : resolvedImageUrl = resolvedImageUrl ?? MediaUrlResolver.resolve(image);

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final rawImg = json['image']?.toString() ?? '';
    return BannerModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      image: rawImg,
      resolvedImageUrl: MediaUrlResolver.resolve(rawImg),
      linkType: json['link_type']?.toString() ?? 'none',
      linkId: json['link_id']?.toString(),
      linkUrl: json['link_url']?.toString(),
      position: json['position']?.toString() ?? 'home_slider',
      sortOrder: json['sort_order'] is num
          ? (json['sort_order'] as num).toInt()
          : (int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString() == 'true' ||
          json['is_active']?.toString() == '1',
      startAt: json['start_at']?.toString(),
      endAt: json['end_at']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'link_type': linkType,
      'link_id': linkId,
      'link_url': linkUrl,
      'position': position,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_at': startAt,
      'end_at': endAt,
    };
  }
}
