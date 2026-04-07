class UserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? profileImage;
  final String role;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.profileImage,
    required this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  String get fullProfileImageUrl {
    if (profileImage == null || profileImage!.isEmpty) return '';
    if (profileImage!.contains('default.jfif')) return '';
    if (profileImage!.startsWith('http')) return profileImage!;
    
    // Modify how we handle 'public/' based on your actual server response
    final cleanPath = profileImage!.replaceFirst('public/', '');
    return "http://192.168.1.32:8000/$cleanPath";
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['fname'],
      lastName: json['lname'],
      email: json['email'],
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      profileImage: json['profile_image']?.toString(),
      role: json['role'] ?? 'customer',
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class PaginationMetadata {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int? from;
  final int? to;
  final List<dynamic> links;

  PaginationMetadata({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    required this.links,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      from: json['from'],
      to: json['to'],
      links: json['links'] ?? [],
    );
  }
}

class UsersResponse {
  final List<UserModel> users;
  final PaginationMetadata pagination;

  UsersResponse({
    required this.users,
    required this.pagination,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'];
    
    List<dynamic> usersList = [];
    Map<String, dynamic> paginationNode = {};

    if (dataNode is List) {
      usersList = dataNode;
      paginationNode = json;
    } else if (dataNode is Map<String, dynamic>) {
      usersList = dataNode['data'] as List<dynamic>? ?? [];
      paginationNode = dataNode;
    }

    return UsersResponse(
      users: usersList.map((userJson) => UserModel.fromJson(userJson)).toList(),
      pagination: PaginationMetadata.fromJson(paginationNode),
    );
  }
}
