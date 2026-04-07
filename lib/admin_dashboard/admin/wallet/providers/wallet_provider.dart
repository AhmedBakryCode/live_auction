import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';
import '../models/transaction_model.dart';
import '../../../core/services/token_manager.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _repository = WalletRepository();
  
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingTransactions = false;
  String? _errorMessage;

  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWalletDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wallet = await _repository.fetchWalletDetails();
      await fetchTransactions(); // implicitly load transactions if wallet exists
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (_errorMessage!.contains('انتهت صلاحية الجلسة') || _errorMessage!.contains('Unauthenticated')) {
          await TokenManager.clearToken();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _isLoadingTransactions = true;
    notifyListeners();

    try {
      _transactions = await _repository.fetchTransactions();
    } catch (e) {
      // Don't override wallet loading error if any
      // but maybe capture it to a separate transaction error string if needed
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWallet() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.deleteWallet();
      if (success) {
        _wallet = null;
        _transactions = [];
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (_errorMessage!.contains('انتهت صلاحية الجلسة') || _errorMessage!.contains('Unauthenticated')) {
          await TokenManager.clearToken();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
