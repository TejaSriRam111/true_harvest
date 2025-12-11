import 'dart:convert';

class AddressModel {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String? deliveryInstructions;
  final bool isDefault;
  final bool isCurrentLocation;

  const AddressModel({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.country = 'India',
    this.deliveryInstructions,
    this.isDefault = false,
    this.isCurrentLocation = false,
  });

  // Empty address
  factory AddressModel.empty() => const AddressModel(
        id: '',
        name: '',
        street: '',
        city: '',
        state: '',
        zip: '',
      );

  // Convert to JSON
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'deliveryInstructions': deliveryInstructions,
      'isDefault': isDefault,
      'isCurrentLocation': isCurrentLocation,
    });
  }

  // Create from JSON
  factory AddressModel.fromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return AddressModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zip: data['zip'] ?? '',
      country: data['country'] ?? 'India',
      deliveryInstructions: data['deliveryInstructions'],
      isDefault: data['isDefault'] ?? false,
      isCurrentLocation: data['isCurrentLocation'] ?? false,
    );
  }

  // Get full address
  String get fullAddress {
    final parts = [
      street,
      city,
      state,
      zip,
      country,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  // Copy with method
  AddressModel copyWith({
    String? id,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? deliveryInstructions,
    bool? isDefault,
    bool? isCurrentLocation,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isDefault: isDefault ?? this.isDefault,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}