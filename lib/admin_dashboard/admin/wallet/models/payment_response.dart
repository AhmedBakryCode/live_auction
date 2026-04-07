class PaymentResponse {
  final String message;
  final String type;
  final String url;
  final int paymentId;

  PaymentResponse({
    required this.message,
    required this.type,
    required this.url,
    required this.paymentId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PaymentResponse(
      message: json['message'] ?? '',
      type: data['type'] ?? '',
      url: data['url'] ?? '',
      paymentId: data['payment_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': {
        'type': type,
        'url': url,
        'payment_id': paymentId,
      }
    };
  }
}
