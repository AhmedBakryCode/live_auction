class AuctionModel {
  final int id;
  final String title;
  final String? description;
  final double startPrice;
  final String? image;
  final String startTime;
  final String endTime;
  final String status;
  final int createdBy;
  final double? currentPrice;
  final double? entryFee;
  final int? highestBidderId;
  final int? winnerId;
  final String? paymentStatus;
  final String? paymentDeadline;
  final String? closedAt;
  final String? createdAt;
  final String? updatedAt;

  AuctionModel({
    required this.id,
    required this.title,
    this.description,
    required this.startPrice,
    this.image,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdBy,
    this.currentPrice,
    this.entryFee,
    this.highestBidderId,
    this.winnerId,
    this.paymentStatus,
    this.paymentDeadline,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  });

  // Images disabled - backend storage not configured
  String? get imageUrl => null;

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startPrice: double.tryParse(json['start_price']?.toString() ?? '0') ?? 0.0,
      image: json['image'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'] ?? 'pending',
      createdBy: json['created_by'],
      currentPrice: json['current_price'] != null ? double.tryParse(json['current_price'].toString()) : null,
      entryFee: json['entry_fee'] != null ? double.tryParse(json['entry_fee'].toString()) : null,
      highestBidderId: json['highest_bidder_id'],
      winnerId: json['winner_id'],
      paymentStatus: json['payment_status'],
      paymentDeadline: json['payment_deadline'],
      closedAt: json['closed_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AuctionsResponse {
  final String message;
  final List<AuctionModel> auctions;
  final int currentPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  AuctionsResponse({
    required this.message,
    required this.auctions,
    required this.currentPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory AuctionsResponse.fromJson(Map<String, dynamic> json) {
    final dataNode = json['data'] ?? {};
    final auctionsList = dataNode['data'] as List<dynamic>? ?? [];
    
    return AuctionsResponse(
      message: json['message'] ?? '',
      auctions: auctionsList.map((j) => AuctionModel.fromJson(j)).toList(),
      currentPage: dataNode['current_page'] ?? 1,
      total: dataNode['total'] ?? 0,
      nextPageUrl: dataNode['next_page_url'],
      prevPageUrl: dataNode['prev_page_url'],
    );
  }
}

