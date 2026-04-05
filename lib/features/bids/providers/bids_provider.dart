import 'package:flutter/material.dart';
import '../models/user_bid_model.dart';
import '../repositories/bids_repository.dart';

class BidsProvider with ChangeNotifier {
  final BidsRepository _repository = BidsRepository();

  List<UserBidModel> _userBids = [];
  List<UserBidModel> get userBids => _userBids;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUserBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userBids = await _repository.fetchUserBids();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
