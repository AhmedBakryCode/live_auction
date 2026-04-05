import 'package:flutter/material.dart';
import '../repository/dashboard_repository.dart';
import '../models/dashboard_stats.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();
  DashboardStats _stats = DashboardStats.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _repository.fetchDashboardStats();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
