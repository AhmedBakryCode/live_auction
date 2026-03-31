class Auction {
  final String id;
  final String product;
  final String startPrice;
  final String topBidder;
  final String status;
  final String timeRemaining;
  final int bids;

  Auction({
    required this.id,
    required this.product,
    required this.startPrice,
    required this.topBidder,
    required this.status,
    required this.timeRemaining,
    required this.bids,
  });
}
