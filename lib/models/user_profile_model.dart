class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String? address;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? occupation;
  final String? dateOfBirth;
  final String? aadhar;
  final bool isVerified;
  final DateTime? createdAt;
  final bool? isFormFilled;
  final Map<String, dynamic>? additionalData;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.address,
    this.firstName,
    this.lastName,
    this.gender,
    this.occupation,
    this.dateOfBirth,
    this.aadhar,
    required this.isVerified,
    this.createdAt,
    this.additionalData,
    this.isFormFilled = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? read(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k].toString();
      }
      return null;
    }

    return UserProfile(
      id: read(json, ['id', 'user_id']) ?? '',
      name: read(json, ['name', 'full_name']) ?? '',
      email: read(json, ['email', 'user_email']) ?? '',
      mobile: read(json, ['mobile', 'phone', 'phone_number']) ?? '',
      address: read(json, ['address', 'addr']),
      firstName: read(json, ['firstName', 'first_name', 'firstname']),
      lastName: read(json, ['lastName', 'last_name', 'lastname']),
      gender: read(json, ['gender']),
      occupation: read(json, ['occupation', 'job']),
      dateOfBirth: read(json, ['dateOfBirth', 'dob', 'date_of_birth']),
      aadhar: read(json, ['aadhar', 'aadhaar', 'aadhar_number']),
      isVerified: (json['is_verified'] ?? json['verified'] ?? false) as bool,
      isFormFilled: json['isFormFilled'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
  
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'address': address,
     'isFormFilled': true,
      'gender': gender,
      'dob': dateOfBirth,
    };
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, mobile: $mobile, isVerified: $isVerified)';
  }

  bool isCompleteForRegistration() {
    final map = additionalData ?? <String, dynamic>{};

    bool present(String? v, List<String> altKeys) {
      if (v != null && v.trim().isNotEmpty) return true;
      for (final k in altKeys) {
        if (map.containsKey(k) && map[k] != null && map[k].toString().trim().isNotEmpty) return true;
      }
      return false;
    }

    final firstNamePresent = present(firstName, ['first_name', 'firstName']);
    final lastNamePresent = present(lastName, ['last_name', 'lastName']);
    final genderPresent = present(gender, ['gender']);
    final occupationPresent = present(occupation, ['occupation']);
    final dobPresent = present(dateOfBirth, ['date_of_birth', 'dob', 'dateOfBirth']);
    final aadharPresent = present(aadhar, ['aadhar', 'aadhaar']);
    final addressPresent = present(address, ['address']);
    final emailPresent = present(email, ['email']);
    final mobilePresent = present(mobile, ['mobile', 'phone']);

    return firstNamePresent && lastNamePresent && genderPresent && occupationPresent &&
        dobPresent && aadharPresent && addressPresent && emailPresent && mobilePresent;
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? firstName,
    String? lastName,
    String? gender,
    String? occupation,
    String? dateOfBirth,
    String? aadhar,
    bool? isVerified,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      aadhar: aadhar ?? this.aadhar,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
