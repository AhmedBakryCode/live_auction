import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsRepository _repository = NotificationsRepository();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Track IDs currently being marked to prevent double-taps
  final Set<int> _markingReadIds = {};
  bool isMarkingRead(int id) => _markingReadIds.contains(id);

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.fetchNotifications();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    _unreadCount = await _repository.fetchUnreadCount();
    notifyListeners();
  }

  Future<bool> markAsRead(int id) async {
    if (_markingReadIds.contains(id)) return false;

    _markingReadIds.add(id);
    notifyListeners();

    try {
      await _repository.markAsRead(id);

      // Sync UI instantly with backend response
      _notifications = _notifications.map((n) {
        if (n.id == id) return n.copyWith(readAt: DateTime.now().toIso8601String());
        return n;
      }).toList();

      // Refresh unread count from backend to stay in sync
      await loadUnreadCount();

      return true;
    } catch (_) {
      return false;
    } finally {
      _markingReadIds.remove(id);
      notifyListeners();
    }
  }

  bool _isMarkingAll = false;
  bool get isMarkingAll => _isMarkingAll;

  Future<bool> markAllAsRead() async {
    if (_isMarkingAll) return false;
    _isMarkingAll = true;
    notifyListeners();

    try {
      await _repository.markAllAsRead();

      // Mark all locally as read (synced with backend)
      final now = DateTime.now().toIso8601String();
      _notifications = _notifications.map((n) => n.copyWith(readAt: now)).toList();

      // Reset unread count globally
      _unreadCount = 0;
      notifyListeners();

      return true;
    } catch (_) {
      return false;
    } finally {
      _isMarkingAll = false;
      notifyListeners();
    }
  }
}
