class SavingsGoalModel {
  final int id;
  final int userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String? eta;
  final String? color;
  final DateTime? createdAt;

  SavingsGoalModel({
    required this.id,
    this.userId = 0,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.eta,
    this.color,
    this.createdAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    final targetRaw = json['target'] ?? json['target_amount'] ?? 0.0;
    final savedRaw = json['saved'] ?? json['saved_amount'] ?? 0.0;

    return SavingsGoalModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      targetAmount: (targetRaw is num) ? targetRaw.toDouble() : double.tryParse(targetRaw.toString()) ?? 0.0,
      savedAmount: (savedRaw is num) ? savedRaw.toDouble() : double.tryParse(savedRaw.toString()) ?? 0.0,
      eta: json['eta'],
      color: json['color'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': targetAmount,
    };
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, double.infinity);
}
