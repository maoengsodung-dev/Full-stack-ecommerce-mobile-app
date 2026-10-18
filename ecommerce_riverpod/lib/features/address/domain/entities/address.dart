class Address {
  final int id;
  final String label;
  final String recipientName;
  final String? addressLine2;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    this.addressLine2,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [
      address,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      country,
    ];
    return parts.join(', ');
  }
}
