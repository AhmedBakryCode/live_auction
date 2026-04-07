class LeaderboardData {
  final List<TopWinner> topWinners;
  final List<TopBidder> topBidders;
  final List<TopSpender> topSpenders;

  LeaderboardData({
    required this.topWinners,
    required this.topBidders,
    required this.topSpenders,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      topWinners: (json['top_winners'] as List?)
              ?.map((e) => TopWinner.fromJson(e))
              .toList() ??
          [],
      topBidders: (json['top_bidders'] as List?)
              ?.map((e) => TopBidder.fromJson(e))
              .toList() ??
          [],
      topSpenders: (json['top_spenders'] as List?)
              ?.map((e) => TopSpender.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TopWinner {
  final int winnerId;
  final int wins;
  final dynamic creator; // Keep dynamic or map to User if applicable

  TopWinner({
    required this.winnerId,
    required this.wins,
    this.creator,
  });

  factory TopWinner.fromJson(Map<String, dynamic> json) {
    return TopWinner(
      winnerId: json['winner_id'] ?? 0,
      wins: json['wins'] ?? 0,
      creator: json['creator'],
    );
  }
}

class TopBidder {
  final int userId;
  final int bidsCount;

  TopBidder({
    required this.userId,
    required this.bidsCount,
  });

  factory TopBidder.fromJson(Map<String, dynamic> json) {
    return TopBidder(
      userId: json['user_id'] ?? 0,
      bidsCount: json['bids_count'] ?? 0,
    );
  }
}

class TopSpender {
  final int winnerId;
  final String totalSpent;

  TopSpender({
    required this.winnerId,
    required this.totalSpent,
  });

  factory TopSpender.fromJson(Map<String, dynamic> json) {
    return TopSpender(
      winnerId: json['winner_id'] ?? 0,
      totalSpent: json['total_spent']?.toString() ?? '0.00',
    );
  }
}
