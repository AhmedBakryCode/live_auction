import 'package:flutter/foundation.dart';
import '../repositories/payments_repository.dart';
import '../models/payment_response.dart';

class PaymentsProvider with ChangeNotifier {
  final PaymentsRepository _repository = PaymentsRepository();

  bool _isLoading = false;
  String? _error;
  PaymentResponse? _paymentResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  PaymentResponse? get paymentResponse => _paymentResponse;

  Future<PaymentResponse?> initiateDeposit(double amount, String paymentMethod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.initiateDeposit(
        amount: amount,
        paymentMethod: paymentMethod,
      );
      _paymentResponse = response;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearState() {
    _isLoading = false;
    _error = null;
    _paymentResponse = null;
    notifyListeners();
  }
}
