import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/bank_model.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load profile.';
      throw Exception(message);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('photo_data')) {
        await _apiClient.post(ApiEndpoints.photo, data: {'photo_data': data['photo_data']});
      }
      final response = await _apiClient.get(ApiEndpoints.profile);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to update profile.';
      throw Exception(message);
    }
  }

  Future<List<BankModel>> getBanks() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.banks);
      if (response.data is List) {
        return (response.data as List).map((e) => BankModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load banks.';
      throw Exception(message);
    }
  }

  Future<BankModel> addBank(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.banks,
        data: {
          'name': data['name'],
          'account_number': data['account_number'] ?? data['masked_acc'] ?? '1234567890',
          'ifsc_code': data['ifsc_code'] ?? 'HDFC0001234',
        },
      );
      return BankModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to link bank account.';
      throw Exception(message);
    }
  }

  Future<bool> deleteBank(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.bankDetails(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to delete bank.';
      throw Exception(message);
    }
  }

  Future<List<BudgetModel>> getBudgets() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.budgets);
      if (response.data is List) {
        return (response.data as List).map((e) => BudgetModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<BudgetModel> setBudget(Map<String, dynamic> data) async {
    try {
      final category = data['category'] ?? 'Other';
      final amount = data['budget_amount'] ?? 0.0;
      await _apiClient.post(
        ApiEndpoints.budgets,
        data: {category: amount},
      );
      return BudgetModel(id: 0, userId: 0, category: category, budgetAmount: amount);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to set budget.';
      throw Exception(message);
    }
  }

  Future<UserModel> toggleReminders() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.reminders);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to update reminder settings.';
      throw Exception(message);
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final response = await _apiClient.delete('/api/user/account');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to delete account.';
      throw Exception(message);
    }
  }
}
