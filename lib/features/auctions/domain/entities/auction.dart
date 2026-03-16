import 'package:equatable/equatable.dart';

class Auction extends Equatable {
  final String id;
  final String title;
  final String description;
  final double currentBid;
  final DateTime endTime;
  final String imageUrl;
  final int totalBids;
  final String sellerName;
  final String? sellerAvatar;

  const Auction({
    required this.id,
    required this.title,
    required this.description,
    required this.currentBid,
    required this.endTime,
    required this.imageUrl,
    required this.totalBids,
    required this.sellerName,
    this.sellerAvatar,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        currentBid,
        endTime,
        imageUrl,
        totalBids,
        sellerName,
        sellerAvatar,
      ];
}
