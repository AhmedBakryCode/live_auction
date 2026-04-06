import 'package:equatable/equatable.dart';

class Auction extends Equatable {
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

  const Auction({
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

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isUpcoming => status == 'upcoming' || status == 'pending';
  bool get isPaid => paymentStatus == 'paid';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startPrice,
    currentPrice,
    startTime,
    endTime,
    image,
    status,
    createdBy,
    highestBidderId,
    winnerId,
    entryFee,
    paymentStatus,
    closedAt,
    paymentDeadline,
    createdAt,
    updatedAt,
  ];
}
