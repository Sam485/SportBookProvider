class PaymentDto {
  final int id;
  final int amount;
  final String method;
  final String status;
  final String transactionRef;
  final String proofImageUrl;
  final DateTime? paidAt;
  final String? note;
  final DateTime createdAt;

  PaymentDto({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionRef,
    required this.proofImageUrl,
    this.paidAt,
    this.note,
    required this.createdAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0,
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
      proofImageUrl: json['proof_image_url'] ?? 0,
      paidAt: json['paid_at'],
      note: json['note'],
      createdAt: json['created_at'] ?? DateTime(0),
    );
  }

  PaymentDto copyWith(
    int? id,
    int? amount,
    String? method,
    String? status,
    String? transactionRef,
    String? proofImageUrl,
    DateTime? paidAt,
    String? note,
    DateTime? createdAt,
  ) {
    return PaymentDto(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionRef: transactionRef ?? this.transactionRef,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
