import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auction.dart';

part 'auction_model.g.dart';

@JsonSerializable()
class AuctionModel extends Auction {
  const AuctionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.currentBid,
    required super.endTime,
    required super.imageUrl,
    required super.totalBids,
    required super.sellerName,
    super.sellerAvatar,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) =>
      _$AuctionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionModelToJson(this);
}
