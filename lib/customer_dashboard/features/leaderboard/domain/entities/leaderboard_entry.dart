import 'package:equatable/equatable.dart';

class LeaderboardUser extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? profileImage;

  const LeaderboardUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    address,
    profileImage,
  ];
}

class LeaderboardEntry extends Equatable {
  final int winnerId;
  final int wins;
  final LeaderboardUser? winner;

  const LeaderboardEntry({
    required this.winnerId,
    required this.wins,
    this.winner,
  });

  @override
  List<Object?> get props => [winnerId, wins, winner];
}

class TopBidder extends Equatable {
  final int userId;
  final int auctionsParticipated;
  final LeaderboardUser? user;

  const TopBidder({
    required this.userId,
    required this.auctionsParticipated,
    this.user,
  });

  @override
  List<Object?> get props => [userId, auctionsParticipated, user];
}

class TopSpender extends Equatable {
  final int winnerId;
  final double totalSpent;
  final LeaderboardUser? winner;

  const TopSpender({
    required this.winnerId,
    required this.totalSpent,
    this.winner,
  });

  @override
  List<Object?> get props => [winnerId, totalSpent, winner];
}

class LeaderboardData extends Equatable {
  final List<LeaderboardEntry> topWinners;
  final List<TopBidder> topBidders;
  final List<TopSpender> topSpenders;

  const LeaderboardData({
    required this.topWinners,
    required this.topBidders,
    required this.topSpenders,
  });

  @override
  List<Object?> get props => [topWinners, topBidders, topSpenders];
}
