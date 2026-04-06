class BidModel {
  final int id;
  final int auctionId;
  final int userId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BidUserModel user;

  BidModel({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] as int,
      auctionId: json['auction_id'] as int,
      userId: json['user_id'] as int,
      amount: _parseDouble(json['amount']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: BidUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auction_id': auctionId,
      'user_id': userId,
      'amount': amount.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class BidUserModel {
  final int id;
  final String fname;
  final String lname;
  final String email;
  final String? emailVerifiedAt;
  final String phone;
  final String address;
  final String? profileImage;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$fname $lname';

  BidUserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    this.emailVerifiedAt,
    required this.phone,
    required this.address,
    this.profileImage,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BidUserModel.fromJson(Map<String, dynamic> json) {
    return BidUserModel(
      id: json['id'] as int,
      fname: json['fname'] as String,
      lname: json['lname'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String,
      profileImage: json['profile_image'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
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
