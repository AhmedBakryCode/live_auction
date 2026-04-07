class DashboardStats {
  final int totalAuctions;
  final int activeAuctions;
  final int closedAuctions;
  final int repostedAuctions;
  final int totalUsers;
  final int totalParticipants;
  final int totalBids;
  final dynamic refundRevenue; // dynamic because it could be double/int or currency string

  DashboardStats({
    required this.totalAuctions,
    required this.activeAuctions,
    required this.closedAuctions,
    required this.repostedAuctions,
    required this.totalUsers,
    required this.totalParticipants,
    required this.totalBids,
    required this.refundRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAuctions: json['total_auctions'] ?? 0,
      activeAuctions: json['active_auctions'] ?? 0,
      closedAuctions: json['closed_auctions'] ?? 0,
      repostedAuctions: json['reposted_auctions'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalParticipants: json['total_participants'] ?? 0,
      totalBids: json['total_bids'] ?? 0,
      refundRevenue: json['refund revenue'] ?? 0,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalAuctions: 0,
      activeAuctions: 0,
      closedAuctions: 0,
      repostedAuctions: 0,
      totalUsers: 0,
      totalParticipants: 0,
      totalBids: 0,
      refundRevenue: 0,
    );
  }
}
