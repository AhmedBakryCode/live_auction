import 'package:equatable/equatable.dart';

class UserBid extends Equatable {
  final int id;
  final int auctionId;
  final int userId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuctionSummary auction;

  const UserBid({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.auction,
  });

  @override
  List<Object?> get props => [id, auctionId, userId, amount, createdAt, updatedAt, auction];
}

class AuctionSummary extends Equatable {
  final int id;
  final String title;
  final String description;
  final double startPrice;
  final double currentPrice;
  final DateTime startTime;
  final DateTime endTime;
  final String? image;
  final String status;
  final int createdBy;
  final int? highestBidderId;
  final int? winnerId;
  final double entryFee;
  final String paymentStatus;
  final DateTime? closedAt;
  final DateTime? paymentDeadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuctionSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.startPrice,
    required this.currentPrice,
    required this.startTime,
    required this.endTime,
    this.image,
    required this.status,
    required this.createdBy,
    this.highestBidderId,
    this.winnerId,
    required this.entryFee,
    required this.paymentStatus,
    this.closedAt,
    this.paymentDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isClosed => status == 'closed';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
    id, title, description, startPrice, currentPrice, startTime, endTime,
    image, status, createdBy, highestBidderId, winnerId, entryFee,
    paymentStatus, closedAt, paymentDeadline, createdAt, updatedAt,
  ];
}
