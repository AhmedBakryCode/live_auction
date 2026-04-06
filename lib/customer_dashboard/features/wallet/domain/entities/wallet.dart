import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    balance,
    status,
    createdAt,
    updatedAt,
  ];
}

class WalletTransaction extends Equatable {
  final int id;
  final int walletId;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal' || type == 'bid';

  @override
  List<Object?> get props => [
    id,
    walletId,
    userId,
    amount,
    type,
    description,
    createdAt,
    updatedAt,
  ];
}

class WalletData extends Equatable {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const WalletData({required this.wallet, required this.transactions});

  @override
  List<Object?> get props => [wallet, transactions];
}

class DepositResponse extends Equatable {
  final String message;
  final String type;
  final String? url;
  final int? paymentId;
  final String? apiKey;
  final String? iframeId;
  final int? integrationCardId;
  final int? integrationMobileWalletId;
  final double? amount;
  final String? paymentMethod;

  const DepositResponse({
    required this.message,
    required this.type,
    this.url,
    this.paymentId,
    this.apiKey,
    this.iframeId,
    this.integrationCardId,
    this.integrationMobileWalletId,
    this.amount,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    message,
    type,
    url,
    paymentId,
    apiKey,
    iframeId,
    integrationCardId,
    integrationMobileWalletId,
    amount,
    paymentMethod,
  ];
}
