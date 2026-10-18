class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  final String? commune;
  final String? addressLine2;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    this.commune,
    this.addressLine2,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      label: json['label']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address_line_1']?.toString() ?? json['address']?.toString() ?? '',
      city: json['province']?.toString() ?? json['city']?.toString() ?? '',
      state: json['district']?.toString() ?? json['state']?.toString() ?? '',
      commune: json['commune']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      postalCode: json['postal_code']?.toString() ?? json['zip_code']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Cambodia',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    if (label.isNotEmpty) 'label': label,
    'recipient_name': recipientName,
    'phone': phone,
    'address_line_1': address,
    if (addressLine2 != null && addressLine2!.isNotEmpty) 'address_line_2': addressLine2,
    'province': city,
    if (state.isNotEmpty) 'district': state,
    if (commune != null && commune!.isNotEmpty) 'commune': commune,
    if (postalCode.isNotEmpty) 'postal_code': postalCode,
    'country': country,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'is_default': isDefault,
  };

  String get fullAddress {
    final parts = [
      address,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (commune != null && commune!.isNotEmpty) commune,
      if (state.isNotEmpty) state,
      city,
      if (postalCode.isNotEmpty) postalCode,
      country,
    ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  AddressModel copyWith({
    int? id,
    String? label,
    String? recipientName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? commune,
    String? addressLine2,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      commune: commune ?? this.commune,
      addressLine2: addressLine2 ?? this.addressLine2,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
