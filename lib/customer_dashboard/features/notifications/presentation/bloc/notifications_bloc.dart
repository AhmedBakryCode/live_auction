import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

// Events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;
  const MarkNotificationAsRead(this.notificationId);
  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class ReceiveRealTimeNotification extends NotificationsEvent {
  final Notification notification;
  const ReceiveRealTimeNotification(this.notification);
  @override
  List<Object> get props => [notification];
}

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<Notification> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  List<Object> get props => [notifications];

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository repository;

  NotificationsBloc(this.repository) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<ReceiveRealTimeNotification>(_onReceiveRealTimeNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());

    final result = await repository.getNotifications();

    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final result = await repository.markAsRead(event.notificationId);

      result.fold((failure) => emit(NotificationsError(failure.message)), (_) {
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return NotificationModel(
              id: n.id,
              type: n.type,
              notifiableType: n.notifiableType,
              notifiableId: n.notifiableId,
              data: n.data,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
            );
          }
          return n;
        }).toList();
        emit(NotificationsLoaded(updatedNotifications));
      });
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final result = await repository.markAllAsRead();

      result.fold((failure) => emit(NotificationsError(failure.message)), (_) {
        final updatedNotifications = currentState.notifications.map((n) {
          if (!n.isRead) {
            return NotificationModel(
              id: n.id,
              type: n.type,
              notifiableType: n.notifiableType,
              notifiableId: n.notifiableId,
              data: n.data,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
            );
          }
          return n;
        }).toList();
        emit(NotificationsLoaded(updatedNotifications));
      });
    }
  }

  void _onReceiveRealTimeNotification(
    ReceiveRealTimeNotification event,
    Emitter<NotificationsState> emit,
  ) {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedNotifications = [
        event.notification,
        ...currentState.notifications,
      ];
      emit(NotificationsLoaded(updatedNotifications));
    } else if (currentState is NotificationsInitial) {
      emit(NotificationsLoaded([event.notification]));
    }
  }
}
