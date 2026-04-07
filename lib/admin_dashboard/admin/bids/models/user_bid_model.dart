class UserBidModel {
  final int id;
  final int auctionId;
  final int userId;
  final double amount;
  final String createdAt;
  final String updatedAt;

  UserBidModel({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBidModel.fromJson(Map<String, dynamic> json) {
    return UserBidModel(
      id: json['id'],
      auctionId: json['auction_id'],
      userId: json['user_id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
