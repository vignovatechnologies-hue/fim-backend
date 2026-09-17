import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import '../services/loan_service.dart';

class LoansProvider extends ChangeNotifier {
  final LoanService _loanService;

  List<LoanModel> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  LoansProvider(this._loanService);

  List<LoanModel> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalMonthlyEmi => _loans.fold(0.0, (sum, item) => sum + item.emi);
  double get totalOutstanding => _loans.fold(0.0, (sum, item) => sum + item.leftAmount);

  Future<void> fetchLoans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loans = await _loanService.getLoans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLoan(Map<String, dynamic> loanData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newLoan = await _loanService.addLoan(loanData);
      _loans.insert(0, newLoan);
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

  Future<bool> togglePayLoan(LoanModel loan) async {
    try {
      final updatedLoan = loan.paidThisMonth
          ? await _loanService.unpayLoan(loan.id)
          : await _loanService.payLoan(loan.id);

      final index = _loans.indexWhere((l) => l.id == loan.id);
      if (index != -1) {
        _loans[index] = updatedLoan;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLoan(int id) async {
    try {
      final success = await _loanService.deleteLoan(id);
      if (success) {
        _loans.removeWhere((l) => l.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
