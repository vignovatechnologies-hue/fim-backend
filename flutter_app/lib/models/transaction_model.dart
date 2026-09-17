class TransactionModel {
  final int id;
  final int userId;
  final String name;
  final String category;
  final double amount;
  final String paymentStatus; // 'credit' or 'debit'
  final DateTime when;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.amount,
    required this.paymentStatus,
    required this.when,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = (json['amount'] is num)
        ? (json['amount'] as num).toDouble()
        : double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0;
    
    final status = (json['payment_status']?.toString().toLowerCase()) ??
        (rawAmount > 0 ? 'credit' : 'debit');

    return TransactionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? json['cat'] ?? 'General',
      amount: rawAmount,
      paymentStatus: status,
      when: json['when'] != null ? DateTime.tryParse(json['when']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'amount': amount,
      'payment_status': paymentStatus,
      'when': when.toIso8601String(),
    };
  }

  bool get isCredit => paymentStatus.toLowerCase() == 'credit' || amount > 0;
}
