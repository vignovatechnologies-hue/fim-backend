class LoanModel {
  final int id;
  final int userId;
  final String name;
  final String type; // Home, Personal, Auto, Education, Consumer
  final double emi;
  final double leftAmount;
  final int totalTenure;
  final int paidTenure;
  final double rate;
  final int dueDay;
  final String logo;
  final bool paidThisMonth;
  final double? originalAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  LoanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.emi,
    required this.leftAmount,
    required this.totalTenure,
    this.paidTenure = 0,
    required this.rate,
    required this.dueDay,
    this.logo = 'bank',
    this.paidThisMonth = false,
    this.originalAmount,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    // Parse left amount supporting both left_amount and left
    final rawLeft = json['left_amount'] ?? json['left'] ?? 0.0;
    final leftAmount = (rawLeft is num) ? rawLeft.toDouble() : double.tryParse(rawLeft.toString()) ?? 0.0;

    // Parse due day supporting both due_day and due
    final rawDue = json['due_day'] ?? json['due'] ?? 5;
    final dueDay = (rawDue is num) ? rawDue.toInt() : int.tryParse(rawDue.toString()) ?? 5;

    // Parse paid status
    final rawPaid = json['paid_this_month'] ?? json['paid'] ?? false;
    final paidThisMonth = rawPaid is bool ? rawPaid : (rawPaid.toString().toLowerCase() == 'true');

    // Parse tenures
    int totalTenure = 24;
    int paidTenure = 0;
    if (json['total_tenure'] != null) {
      totalTenure = (json['total_tenure'] is num) ? (json['total_tenure'] as num).toInt() : int.tryParse(json['total_tenure'].toString()) ?? 24;
    }
    if (json['paid_tenure'] != null) {
      paidTenure = (json['paid_tenure'] is num) ? (json['paid_tenure'] as num).toInt() : int.tryParse(json['paid_tenure'].toString()) ?? 0;
    }
    if (json['tenure'] != null && json['tenure'].toString().contains('/')) {
      final parts = json['tenure'].toString().split('/');
      if (parts.length == 2) {
        paidTenure = int.tryParse(parts[0].trim()) ?? paidTenure;
        totalTenure = int.tryParse(parts[1].trim()) ?? totalTenure;
      }
    }

    return LoanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'Personal',
      emi: (json['emi'] is num) ? (json['emi'] as num).toDouble() : double.tryParse(json['emi']?.toString() ?? '0.0') ?? 0.0,
      leftAmount: leftAmount,
      totalTenure: totalTenure,
      paidTenure: paidTenure,
      rate: (json['rate'] is num) ? (json['rate'] as num).toDouble() : double.tryParse(json['rate']?.toString() ?? '0.0') ?? 0.0,
      dueDay: dueDay,
      logo: json['logo'] ?? 'bank',
      paidThisMonth: paidThisMonth,
      originalAmount: json['original_amount'] != null ? (json['original_amount'] as num).toDouble() : null,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'emi': emi,
      'left_amount': leftAmount,
      'total_tenure': totalTenure,
      'paid_tenure': paidTenure,
      'rate': rate,
      'due_day': dueDay,
      'logo': logo,
      'paid_this_month': paidThisMonth,
      'original_amount': originalAmount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  double get progressPercentage {
    if (totalTenure <= 0) return 0.0;
    return (paidTenure / totalTenure).clamp(0.0, 1.0);
  }

  int get remainingTenure => (totalTenure - paidTenure).clamp(0, totalTenure);
}
