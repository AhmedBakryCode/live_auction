import 'package:equatable/equatable.dart';

class ParticipatedAuction extends Equatable {
  final String title;
  final String description;
  final double startPrice;
  final DateTime startTime;
  final DateTime endTime;
  final String image;

  const ParticipatedAuction({
    required this.title,
    required this.description,
    required this.startPrice,
    required this.startTime,
    required this.endTime,
    required this.image,
  });

  @override
  List<Object?> get props => [title, description, startPrice, startTime, endTime, image];
}

class UserStats extends Equatable {
  final int totalBids;
  final int auctionsWon;
  final double totalSpent;
  final int joinedAuctionsCount;
  final List<ParticipatedAuction> participatedAuctions;

  const UserStats({
    required this.totalBids,
    required this.auctionsWon,
    required this.totalSpent,
    required this.joinedAuctionsCount,
    required this.participatedAuctions,
  });

  @override
  List<Object?> get props => [
    totalBids,
    auctionsWon,
    totalSpent,
    joinedAuctionsCount,
    participatedAuctions,
  ];
}
