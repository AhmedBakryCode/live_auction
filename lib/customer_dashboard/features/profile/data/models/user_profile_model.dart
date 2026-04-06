import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.emailVerifiedAt,
    required super.phone,
    required super.address,
    required super.profileImage,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return UserProfileModel(
      id: data['id'] ?? 0,
      firstName: data['fname'] ?? '',
      lastName: data['lname'] ?? '',
      email: data['email'] ?? '',
      emailVerifiedAt: data['email_verified_at'],
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      profileImage: data['profile_image'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': firstName,
      'lname': lastName,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
