class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String message;
  final String createdAt;
  final String updatedAt;
  final String? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  NotificationModel copyWith({String? readAt}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      message: message,
      createdAt: createdAt,
      updatedAt: updatedAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'] ?? 'info',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      readAt: json['read_at']?.toString(),
    );
  }
}
