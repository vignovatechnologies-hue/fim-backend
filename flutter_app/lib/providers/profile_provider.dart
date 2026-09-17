import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/bank_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  UserModel? _profile;
  List<BankModel> _banks = [];
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._profileService);

  UserModel? get profile => _profile;
  List<BankModel> get banks => _banks;
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile();
      _banks = await _profileService.getBanks();
      _budgets = await _profileService.getBudgets();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileService.updateProfile(data);
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

  Future<bool> toggleReminders() async {
    try {
      _profile = await _profileService.toggleReminders();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final success = await _profileService.deleteAccount();
      if (success) {
        _profile = null;
        _banks.clear();
        _budgets.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addBank(Map<String, dynamic> data) async {
    try {
      final newBank = await _profileService.addBank(data);
      _banks.add(newBank);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBank(int bankId) async {
    try {
      final success = await _profileService.deleteBank(bankId);
      if (success) {
        _banks.removeWhere((b) => b.id == bankId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> setBudget(String category, double amount) async {
    try {
      final budget = await _profileService.setBudget({
        'category': category,
        'budget_amount': amount,
      });
      final index = _budgets.indexWhere((b) => b.category == category);
      if (index != -1) {
        _budgets[index] = budget;
      } else {
        _budgets.add(budget);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
