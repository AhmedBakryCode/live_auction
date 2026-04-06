import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final NotificationData data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => readAt != null;

  NotificationType get notificationType {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('won') || typeLower.contains('win')) {
      return NotificationType.won;
    } else if (typeLower.contains('outbid')) {
      return NotificationType.outbid;
    } else if (typeLower.contains('ending')) {
      return NotificationType.endingSoon;
    } else {
      return NotificationType.news;
    }
  }

  @override
  List<Object?> get props => [
    id,
    type,
    notifiableType,
    notifiableId,
    data,
    readAt,
    createdAt,
    updatedAt,
  ];
}

class NotificationData extends Equatable {
  final String message;
  final Map<String, dynamic>? additionalData;

  const NotificationData({
    required this.message,
    this.additionalData,
  });

  @override
  List<Object?> get props => [message, additionalData];
}

enum NotificationType { outbid, endingSoon, won, news }
