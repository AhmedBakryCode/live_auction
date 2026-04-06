import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardUserModel extends LeaderboardUser {
  const LeaderboardUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    super.phone,
    super.address,
    super.profileImage,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      id: json['id'] ?? 0,
      firstName: json['fname'] ?? '',
      lastName: json['lname'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': firstName,
      'lname': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
    };
  }
}

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.winnerId,
    required super.wins,
    super.winner,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      winnerId: json['winner_id'] ?? 0,
      wins: json['wins_count'] ?? 0,
      winner: json['winner'] != null
          ? LeaderboardUserModel.fromJson(json['winner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winner_id': winnerId,
      'wins_count': wins,
      'winner': winner != null
          ? (winner as LeaderboardUserModel).toJson()
          : null,
    };
  }
}

class TopBidderModel extends TopBidder {
  const TopBidderModel({
    required super.userId,
    required super.auctionsParticipated,
    super.user,
  });

  factory TopBidderModel.fromJson(Map<String, dynamic> json) {
    return TopBidderModel(
      userId: json['user_id'] ?? 0,
      auctionsParticipated: json['auctions_participated'] ?? 0,
      user: json['user'] != null
          ? LeaderboardUserModel.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'auctions_participated': auctionsParticipated,
      'user': user != null ? (user as LeaderboardUserModel).toJson() : null,
    };
  }
}

class TopSpenderModel extends TopSpender {
  const TopSpenderModel({
    required super.winnerId,
    required super.totalSpent,
    super.winner,
  });

  factory TopSpenderModel.fromJson(Map<String, dynamic> json) {
    final totalSpent = json['total_spent'];
    return TopSpenderModel(
      winnerId: json['winner_id'] ?? 0,
      totalSpent: totalSpent is num ? totalSpent.toDouble() : 0.0,
      winner: json['winner'] != null
          ? LeaderboardUserModel.fromJson(json['winner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winner_id': winnerId,
      'total_spent': totalSpent,
      'winner': winner != null
          ? (winner as LeaderboardUserModel).toJson()
          : null,
    };
  }
}

class LeaderboardDataModel extends LeaderboardData {
  const LeaderboardDataModel({
    required super.topWinners,
    required super.topBidders,
    required super.topSpenders,
  });

  factory LeaderboardDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return LeaderboardDataModel(
      topWinners:
          (data['top_winners'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntryModel.fromJson(e))
              .toList() ??
          [],
      topBidders:
          (data['top_bidders'] as List<dynamic>?)
              ?.map((e) => TopBidderModel.fromJson(e))
              .toList() ??
          [],
      topSpenders:
          (data['top_spenders'] as List<dynamic>?)
              ?.map((e) => TopSpenderModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_winners': topWinners
          .map((e) => (e as LeaderboardEntryModel).toJson())
          .toList(),
      'top_bidders': topBidders
          .map((e) => (e as TopBidderModel).toJson())
          .toList(),
      'top_spenders': topSpenders
          .map((e) => (e as TopSpenderModel).toJson())
          .toList(),
    };
  }
}
