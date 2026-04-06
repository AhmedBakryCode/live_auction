import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.emailVerifiedAt,
    super.phone,
    super.address,
    super.profileImage,
    required super.role,
    required super.token,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested API response: data.user and data.token
    final data = json['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;

    if (user == null || token == null) {
      throw Exception('Invalid API response: missing user or token');
    }

    return UserModel(
      id: user['id'].toString(),
      firstName: user['fname'] as String,
      lastName: user['lname'] as String,
      email: user['email'] as String,
      emailVerifiedAt: user['email_verified_at'] as String?,
      phone: user['phone'] as String?,
      address: user['address'] as String?,
      profileImage: user['profile_image'] as String?,
      role: user['role'] as String,
      token: token,
      createdAt: user['created_at'] as String?,
      updatedAt: user['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
