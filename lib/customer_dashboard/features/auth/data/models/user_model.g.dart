// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  emailVerifiedAt: json['emailVerifiedAt'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  profileImage: json['profileImage'] as String?,
  role: json['role'] as String,
  token: json['token'] as String,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'emailVerifiedAt': instance.emailVerifiedAt,
  'phone': instance.phone,
  'address': instance.address,
  'profileImage': instance.profileImage,
  'role': instance.role,
  'token': instance.token,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
