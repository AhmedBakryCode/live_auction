import '../../users/models/user_model.dart';

class AuctionBidModel {
  final int id;
  final int auctionId;
  final int userId;
  final double amount;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;

  AuctionBidModel({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory AuctionBidModel.fromJson(Map<String, dynamic> json) {
    return AuctionBidModel(
      id: json['id'],
      auctionId: json['auction_id'],
      userId: json['user_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
