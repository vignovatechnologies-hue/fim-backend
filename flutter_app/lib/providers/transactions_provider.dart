import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionService _transactionService;

  List<TransactionModel> _transactions = [];
  List<Map<String, dynamic>> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  TransactionsProvider(this._transactionService);

  List<TransactionModel> get transactions => _transactions;
  List<Map<String, dynamic>> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalIncome => _transactions
      .where((t) => t.isCredit)
      .fold(0.0, (sum, item) => sum + item.amount.abs());

  double get totalExpense => _transactions
      .where((t) => !t.isCredit)
      .fold(0.0, (sum, item) => sum + item.amount.abs());

  int? _selectedMonth = DateTime.now().month;
  int? _selectedYear = DateTime.now().year;

  int? get selectedMonth => _selectedMonth;
  int? get selectedYear => _selectedYear;

  void setSelectedMonth(int? month, int? year) {
    _selectedMonth = month;
    _selectedYear = year;
    fetchTransactions(month: month, year: year);
  }

  Future<void> fetchTransactions({int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final m = month ?? _selectedMonth;
    final y = year ?? _selectedYear;

    try {
      _transactions = await _transactionService.getTransactions(month: m, year: y);
      await fetchBudgets(month: m, year: y);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBudgets({int? month, int? year}) async {
    try {
      _budgets = await _transactionService.getBudgets(
        month: month ?? _selectedMonth,
        year: year ?? _selectedYear,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateBudget(String category, double amount) async {
    try {
      final success = await _transactionService.updateBudgets({category: amount});
      if (success) {
        await fetchBudgets();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchStatement(
    String period, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _transactionService.getStatement(
        period,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return {};
    }
  }

  Future<bool> addTransaction(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _transactionService.addTransaction(data);
      // Reset to current month/year view or current selected month so newly added item reflects
      _selectedMonth = DateTime.now().month;
      _selectedYear = DateTime.now().year;
      await fetchTransactions(month: _selectedMonth, year: _selectedYear);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _transactionService.updateTransaction(id, data);
      await fetchTransactions(month: _selectedMonth, year: _selectedYear);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final success = await _transactionService.deleteTransaction(id);
      if (success) {
        await fetchTransactions(month: _selectedMonth, year: _selectedYear);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
