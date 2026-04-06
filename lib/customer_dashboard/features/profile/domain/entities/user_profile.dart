import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? emailVerifiedAt;
  final String phone;
  final String address;
  final String profileImage;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.emailVerifiedAt,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

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
    createdAt,
    updatedAt,
  ];
}

class UpdateProfileRequest extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String? password;
  final String? passwordConfirmation;
  final String? profileImage;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    this.password,
    this.passwordConfirmation,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fname': firstName,
      'lname': lastName,
      'phone': phone,
      'address': address,
    };
    
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
      data['password_confirmation'] = passwordConfirmation;
    }
    
    if (profileImage != null) {
      data['profile_image'] = profileImage;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    address,
    password,
    passwordConfirmation,
    profileImage,
  ];
}

class ChangePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    };
  }

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}
