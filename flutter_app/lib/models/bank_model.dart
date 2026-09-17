class BankModel {
  final int id;
  final int userId;
  final String name;
  final String maskedAcc;
  final String? ifscCode;
  final DateTime? createdAt;

  BankModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.maskedAcc,
    this.ifscCode,
    this.createdAt,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      maskedAcc: json['masked_acc'] ?? '',
      ifscCode: json['ifsc_code'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'masked_acc': maskedAcc,
      'ifsc_code': ifscCode,
    };
  }
}

class BudgetModel {
  final int id;
  final int userId;
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final String? color;

  BudgetModel({
    required this.id,
    this.userId = 0,
    required this.category,
    required this.budgetAmount,
    this.spentAmount = 0.0,
    this.color,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final rawBudget = json['budget_amount'] ?? json['budget'] ?? 0.0;
    final rawSpent = json['spent_amount'] ?? json['spent'] ?? 0.0;

    return BudgetModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      category: json['category'] ?? json['name'] ?? '',
      budgetAmount: (rawBudget is num) ? rawBudget.toDouble() : double.tryParse(rawBudget.toString()) ?? 0.0,
      spentAmount: (rawSpent is num) ? rawSpent.toDouble() : double.tryParse(rawSpent.toString()) ?? 0.0,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'budget_amount': budgetAmount,
    };
  }
}
