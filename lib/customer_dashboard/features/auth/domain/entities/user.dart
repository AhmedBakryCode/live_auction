import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? emailVerifiedAt;
  final String? phone;
  final String? address;
  final String? profileImage;
  final String role;
  final String token;
  final String? createdAt;
  final String? updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.emailVerifiedAt,
    this.phone,
    this.address,
    this.profileImage,
    required this.role,
    required this.token,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get name => fullName;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    emailVerifiedAt,
    phone,
    address,
    profileImage,
    role,
    token,
    createdAt,
    updatedAt,
  ];
}
