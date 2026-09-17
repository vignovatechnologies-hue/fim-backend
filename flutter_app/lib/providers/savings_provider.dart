import 'package:flutter/material.dart';
import '../models/savings_goal_model.dart';
import '../services/savings_service.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsService _savingsService;

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  SavingsProvider(this._savingsService);

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalSavings => _goals.fold(0.0, (sum, item) => sum + item.savedAmount);
  double get totalTarget => _goals.fold(0.0, (sum, item) => sum + item.targetAmount);

  Future<void> fetchGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _savingsService.getGoals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGoal(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGoal = await _savingsService.addGoal(data);
      _goals.insert(0, newGoal);
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

  Future<bool> updateGoal(int goalId, Map<String, dynamic> data) async {
    try {
      final updatedGoal = await _savingsService.updateGoal(goalId, data);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deposit(int goalId, double amount) async {
    try {
      final updatedGoal = await _savingsService.deposit(goalId, amount);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    try {
      final success = await _savingsService.deleteGoal(goalId);
      if (success) {
        _goals.removeWhere((g) => g.id == goalId);
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
