import 'package:flutter/foundation.dart';
import '../repositories/leaderboard_repository.dart';
import '../models/leaderboard_model.dart';

class LeaderboardProvider with ChangeNotifier {
  final LeaderboardRepository _repository = LeaderboardRepository();

  bool _isLoading = false;
  String? _error;
  LeaderboardData? _leaderboardData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  LeaderboardData? get leaderboardData => _leaderboardData;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaderboardData = await _repository.fetchLeaderboard();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
