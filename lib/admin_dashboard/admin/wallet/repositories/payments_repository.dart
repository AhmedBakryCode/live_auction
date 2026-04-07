import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_response.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class PaymentsRepository extends ApiClient {
  Future<PaymentResponse> initiateDeposit({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      AppLogger.info(
        'PAYMENTS',
        'Initiating deposit for $amount via $paymentMethod',
      );

      final response = await apiPostJson(AppConfig.paymentsDepositEndpoint, {
        'amount': amount,
        'payment_method': paymentMethod,
      });

      AppLogger.network(
        'PAYMENTS',
        response.statusCode,
        AppConfig.paymentsDepositEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return PaymentResponse.fromJson(decoded);
      } else if (response.statusCode == 422) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'بيانات غير صالحة');
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('PAYMENTS', 'Error initiating deposit', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
