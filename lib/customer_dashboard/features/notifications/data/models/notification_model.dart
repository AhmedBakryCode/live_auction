import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.notifiableType,
    required super.notifiableId,
    required super.data,
    super.readAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> 
        ? json['data'] 
        : <String, dynamic>{};
    
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      notifiableType: json['notifiable_type'] ?? '',
      notifiableId: json['notifiable_id'] ?? 0,
      data: NotificationDataModel.fromJson(data),
      readAt: json['read_at'] != null 
          ? DateTime.tryParse(json['read_at']) 
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_type': notifiableType,
      'notifiable_id': notifiableId,
      'data': (data as NotificationDataModel).toJson(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NotificationDataModel extends NotificationData {
  const NotificationDataModel({
    required super.message,
    super.additionalData,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      message: json['message'] ?? '',
      additionalData: json..remove('message'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (additionalData != null) ...additionalData!,
    };
  }
}
