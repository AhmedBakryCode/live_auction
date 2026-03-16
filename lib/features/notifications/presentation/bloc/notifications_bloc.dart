import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsLoaded extends NotificationsState {
  final List<Map<String, dynamic>> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  List<Object> get props => [notifications];
}
class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object> get props => [message];
}

enum NotificationType { outbid, endingSoon, won, news }

// Bloc
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationsLoading());
      
      // Simulate data fetching
      await Future.delayed(const Duration(milliseconds: 800));
      
      final notifications = [
        {
          'id': '1',
          'title': 'لقد فزت بالمزاد!',
          'body': 'مبروك! لقد فزت بمزاد "ساعة رولكس كوزموغراف". يرجى إتمام عملية الدفع.',
          'time': 'منذ 5 دقائق',
          'type': NotificationType.won,
          'isRead': false,
        },
        {
          'id': '2',
          'title': 'تم تخطي مزايدتك',
          'body': 'قام مستخدم آخر بالمزايدة على "سيارة مرسيدس G-Class". زايد الآن لاستعادة الصدارة!',
          'time': 'منذ ساعة',
          'type': NotificationType.outbid,
          'isRead': false,
        },
        {
          'id': '3',
          'title': 'المزاد ينتهي قريباً',
          'body': 'المزاد على "طقم ألماس فاخر" ينتهي خلال 15 دقيقة فقط.',
          'time': 'منذ ساعتين',
          'type': NotificationType.endingSoon,
          'isRead': true,
        },
        {
          'id': '4',
          'title': 'مزادات جديدة متاحة',
          'body': 'تمت إضافة مجموعة جديدة من السيارات الكلاسيكية إلى المزادات اليوم.',
          'time': 'أمس',
          'type': NotificationType.news,
          'isRead': true,
        },
      ];
      
      emit(NotificationsLoaded(notifications));
    });
  }
}
