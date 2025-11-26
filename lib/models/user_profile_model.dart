class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String? address;
  final bool isVerified;
  final DateTime? createdAt;
  final Map<String, dynamic>? additionalData;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.address,
    required this.isVerified,
    this.createdAt,
    this.additionalData,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, mobile: $mobile, isVerified: $isVerified)';
  }
}
