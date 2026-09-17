import 'loan_model.dart';
import 'transaction_model.dart';
import 'savings_goal_model.dart';

class DashboardStatsModel {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyEmiTotal;
  final double totalDebt;
  final double totalSavings;
  final List<LoanModel> upcomingEmis;
  final List<TransactionModel> recentTransactions;
  final List<SavingsGoalModel> savingsGoals;

  DashboardStatsModel({
    this.totalBalance = 0.0,
    this.monthlyIncome = 0.0,
    this.monthlyExpense = 0.0,
    this.monthlyEmiTotal = 0.0,
    this.totalDebt = 0.0,
    this.totalSavings = 0.0,
    this.upcomingEmis = const [],
    this.recentTransactions = const [],
    this.savingsGoals = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalBalance: (json['total_balance'] is num) ? (json['total_balance'] as num).toDouble() : 0.0,
      monthlyIncome: (json['monthly_income'] is num) ? (json['monthly_income'] as num).toDouble() : 0.0,
      monthlyExpense: (json['monthly_expense'] is num) ? (json['monthly_expense'] as num).toDouble() : 0.0,
      monthlyEmiTotal: (json['monthly_emi_total'] is num) ? (json['monthly_emi_total'] as num).toDouble() : 0.0,
      totalDebt: (json['total_debt'] is num) ? (json['total_debt'] as num).toDouble() : 0.0,
      totalSavings: (json['total_savings'] is num) ? (json['total_savings'] as num).toDouble() : 0.0,
      upcomingEmis: (json['upcoming_emis'] as List<dynamic>?)
              ?.map((e) => LoanModel.fromJson(e))
              .toList() ??
          [],
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e))
              .toList() ??
          [],
      savingsGoals: (json['savings_goals'] as List<dynamic>?)
              ?.map((e) => SavingsGoalModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
