import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.walletId,
    required super.userId,
    required super.amount,
    required super.type,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DepositResponseModel extends DepositResponse {
  const DepositResponseModel({
    required super.message,
    required super.type,
    super.url,
    super.paymentId,
    super.apiKey,
    super.iframeId,
    super.integrationCardId,
    super.integrationMobileWalletId,
    super.amount,
    super.paymentMethod,
  });

  factory DepositResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final paymobData = data['paymob'] ?? {};
    return DepositResponseModel(
      message: json['message'] ?? '',
      type: data['type'] ?? '',
      url: data['url'],
      paymentId: data['payment_id'],
      apiKey: paymobData['api_key'],
      iframeId: paymobData['iframe_id'],
      integrationCardId: paymobData['integration_card_id'],
      integrationMobileWalletId: paymobData['integration_wallet_id'],
      amount: data['amount'] != null
          ? double.tryParse(data['amount'].toString())
          : null,
      paymentMethod: data['payment_method'],
    );
  }
}
