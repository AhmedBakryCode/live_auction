import '../../domain/entities/user_bid.dart';

class UserBidModel extends UserBid {
  const UserBidModel({
    required super.id,
    required super.auctionId,
    required super.userId,
    required super.amount,
    required super.createdAt,
    required super.updatedAt,
    required super.auction,
  });

  factory UserBidModel.fromJson(Map<String, dynamic> json) {
    return UserBidModel(
      id: json['id'] as int,
      auctionId: json['auction_id'] as int,
      userId: json['user_id'] as int,
      amount: _parseDouble(json['amount']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      auction: AuctionSummaryModel.fromJson(json['auction'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auction_id': auctionId,
      'user_id': userId,
      'amount': amount.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'auction': (auction as AuctionSummaryModel).toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class AuctionSummaryModel extends AuctionSummary {
  const AuctionSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startPrice,
    required super.currentPrice,
    required super.startTime,
    required super.endTime,
    super.image,
    required super.status,
    required super.createdBy,
    super.highestBidderId,
    super.winnerId,
    required super.entryFee,
    required super.paymentStatus,
    super.closedAt,
    super.paymentDeadline,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AuctionSummaryModel.fromJson(Map<String, dynamic> json) {
    return AuctionSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startPrice: UserBidModel._parseDouble(json['start_price']),
      currentPrice: UserBidModel._parseDouble(json['current_price']),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      image: json['image'] as String?,
      status: json['status'] as String,
      createdBy: json['created_by'] as int,
      highestBidderId: json['highest_bidder_id'] as int?,
      winnerId: json['winner_id'] as int?,
      entryFee: UserBidModel._parseDouble(json['entry_fee']),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      paymentDeadline: json['payment_deadline'] != null ? DateTime.parse(json['payment_deadline'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_price': startPrice.toString(),
      'current_price': currentPrice.toString(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'image': image,
      'status': status,
      'created_by': createdBy,
      'highest_bidder_id': highestBidderId,
      'winner_id': winnerId,
      'entry_fee': entryFee.toString(),
      'payment_status': paymentStatus,
      'closed_at': closedAt?.toIso8601String(),
      'payment_deadline': paymentDeadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
