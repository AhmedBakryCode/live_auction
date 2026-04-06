import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, List<WalletTransaction>>> getTransactions();
  Future<Either<Failure, DepositResponse>> deposit({
    required double amount,
    required String paymentMethod,
  });
}
