class TransactionModel {
  final int id;
  final String amount;
  final String type;
  final String status;
  final String? description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      type: json['type']?.toString() ?? 'unknown',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
