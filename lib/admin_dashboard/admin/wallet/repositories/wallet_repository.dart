import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class WalletRepository extends ApiClient {
  Future<WalletModel?> fetchWalletDetails() async {
    try {
      AppLogger.info('WALLET', 'Fetching user wallet details...');
      final response = await apiGet(AppConfig.walletGetEndpoint);
      
      AppLogger.network('WALLET', response.statusCode, AppConfig.walletGetEndpoint);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        // Assuming response structure: {"data": {"id": 1, "user_id": 1, "balance": "100.00", ...}}
        // Or {"id": 1, ...} directly. We'll handle both.
        if (decoded.containsKey('data')) {
          if (decoded['data'] == null) {
             throw Exception('محفظة المستخدم غير موجودة');
          }
          return WalletModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return WalletModel.fromJson(decoded);
      } else if (response.statusCode == 404) {
        throw Exception('محفظة المستخدم غير موجودة');
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('WALLET', 'Error fetching wallet', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<bool> deleteWallet() async {
    try {
      AppLogger.info('WALLET', 'Deleting user wallet...');
      final response = await apiDelete(AppConfig.walletDeleteEndpoint);
      
      AppLogger.network('WALLET_DELETE', response.statusCode, AppConfig.walletDeleteEndpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('المحفظة غير موجودة');
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('WALLET_DELETE', 'Error deleting wallet', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      AppLogger.info('WALLET', 'Fetching user wallet transactions...');
      final response = await apiGet(AppConfig.walletTransactionsEndpoint);
      
      AppLogger.network('WALLET_TRANSACTIONS', response.statusCode, AppConfig.walletTransactionsEndpoint);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        // Assume structure {"data": [...]} or just [...]
        List<dynamic> list = [];
        if (decoded.containsKey('data') && decoded['data'] is List) {
          list = decoded['data'] as List;
        } else if (decoded.containsKey('transactions') && decoded['transactions'] is List) {
          list = decoded['transactions'] as List;
        }
        
        return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      final body = json.decode(response.body) as Map<String, dynamic>?;
      throwApiError(response.statusCode, body);
    } catch (e) {
      AppLogger.error('WALLET_TRANSACTIONS', 'Error fetching transactions', e);
      if (e is http.ClientException) {
        throw Exception('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }
}
