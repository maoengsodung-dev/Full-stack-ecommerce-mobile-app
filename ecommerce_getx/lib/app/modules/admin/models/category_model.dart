class AdminCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? image;
  final bool isActive;
  final int productsCount;

  const AdminCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.image,
    this.isActive = true,
    this.productsCount = 0,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active']?.toString() == 'true',
      productsCount: json['products_count'] is num
          ? (json['products_count'] as num).toInt()
          : int.tryParse(json['products_count']?.toString() ?? '0') ?? 0,
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
      'is_active': isActive,
      'products_count': productsCount,
    };
  }
}
