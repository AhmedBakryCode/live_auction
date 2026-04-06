import '../../domain/entities/user_stats.dart';

class ParticipatedAuctionModel extends ParticipatedAuction {
  const ParticipatedAuctionModel({
    required super.title,
    required super.description,
    required super.startPrice,
    required super.startTime,
    required super.endTime,
    required super.image,
  });

  factory ParticipatedAuctionModel.fromJson(Map<String, dynamic> json) {
    return ParticipatedAuctionModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startPrice: double.tryParse(json['start_price']?.toString() ?? '0') ?? 0,
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_price': startPrice,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'image': image,
    };
  }
}

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.totalBids,
    required super.auctionsWon,
    required super.totalSpent,
    required super.joinedAuctionsCount,
    required super.participatedAuctions,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return UserStatsModel(
      totalBids: data['total_bids'] ?? 0,
      auctionsWon: data['auctions_won'] ?? 0,
      totalSpent: double.tryParse(data['total_spent']?.toString() ?? '0') ?? 0,
      joinedAuctionsCount: data['joined_auctions_count'] ?? 0,
      participatedAuctions:
          (data['participated_auctions'] as List<dynamic>?)
              ?.map((e) => ParticipatedAuctionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bids': totalBids,
      'auctions_won': auctionsWon,
      'total_spent': totalSpent,
      'joined_auctions_count': joinedAuctionsCount,
      'participated_auctions': participatedAuctions
          .map((e) => (e as ParticipatedAuctionModel).toJson())
          .toList(),
    };
  }
}
