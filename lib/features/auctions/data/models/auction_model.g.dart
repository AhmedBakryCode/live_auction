// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionModel _$AuctionModelFromJson(Map<String, dynamic> json) => AuctionModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  currentBid: (json['currentBid'] as num).toDouble(),
  endTime: DateTime.parse(json['endTime'] as String),
  imageUrl: json['imageUrl'] as String,
  totalBids: (json['totalBids'] as num).toInt(),
  sellerName: json['sellerName'] as String,
  sellerAvatar: json['sellerAvatar'] as String?,
);

Map<String, dynamic> _$AuctionModelToJson(AuctionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'currentBid': instance.currentBid,
      'endTime': instance.endTime.toIso8601String(),
      'imageUrl': instance.imageUrl,
      'totalBids': instance.totalBids,
      'sellerName': instance.sellerName,
      'sellerAvatar': instance.sellerAvatar,
    };
