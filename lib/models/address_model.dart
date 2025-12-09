// models/address_model.dart
import 'dart:convert';

class AddressModel {
  final String name;
  final String email;
  final String phone;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String? deliveryInstructions;
  final String id;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.apartment,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    this.deliveryInstructions,
    String? id,
    this.isDefault = false,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Getters
  String get fullAddress {
    final parts = [
      street,
      apartment,
      city,
      state,
      zip,
      country,
    ].where((part) => part.isNotEmpty).join(', ');
    return parts;
  }

  String get shortAddress {
    return '$city, $state';
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'street': street,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'deliveryInstructions': deliveryInstructions,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      street: map['street'] as String,
      apartment: map['apartment'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zip: map['zip'] as String,
      country: map['country'] as String,
      deliveryInstructions: map['deliveryInstructions'] as String?,
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Create from JSON
  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source));

  // Copy with method for updates
  AddressModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? street,
    String? apartment,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? deliveryInstructions,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.id == id &&
        other.name == name &&
        other.fullAddress == fullAddress;
  }

  @override
  int get hashCode => id.hashCode;
}