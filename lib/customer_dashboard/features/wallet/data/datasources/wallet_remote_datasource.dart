import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<List<WalletTransactionModel>> getTransactions();
  Future<DepositResponseModel> deposit({
    required double amount,
    required String paymentMethod,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;

  WalletRemoteDataSourceImpl(this.dio);

  @override
  Future<WalletModel> getWallet() async {
    try {
      final response = await dio.get(ApiConstants.walletGet);

      if (response.statusCode == 200) {
        return WalletModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load wallet',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final response = await dio.get(ApiConstants.walletTransactions);

      if (response.statusCode == 200) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map) {
          final responseData = response.data['data'];
          if (responseData is List) {
            data = responseData;
          } else if (responseData is Map && responseData['data'] is List) {
            // Handle paginated response: {data: {data: [], current_page: ...}}
            data = responseData['data'];
          } else {
            data = [];
          }
        } else {
          data = [];
        }
        return data.map((e) => WalletTransactionModel.fromJson(e)).toList();
      } else if (response.statusCode == 500) {
        throw ServerException('خطأ في السيرفر - يرجى المحاولة لاحقاً');
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load transactions',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DepositResponseModel> deposit({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.deposit,
        data: {'amount': amount, 'payment_method': paymentMethod},
      );

      if (response.statusCode == 200) {
        return DepositResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to process deposit',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
