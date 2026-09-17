import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/savings_goal_model.dart';

class SavingsService {
  final ApiClient _apiClient;

  SavingsService(this._apiClient);

  Future<List<SavingsGoalModel>> getGoals() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.savings);
      if (response.data is List) {
        return (response.data as List).map((e) => SavingsGoalModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load savings goals.';
      throw Exception(message);
    }
  }

  Future<SavingsGoalModel> addGoal(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.savings,
        data: {
          'name': data['name'],
          'target': data['target_amount'] ?? data['target'],
        },
      );
      return SavingsGoalModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to add savings goal.';
      throw Exception(message);
    }
  }

  Future<SavingsGoalModel> updateGoal(int goalId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.savings}/$goalId',
        data: {
          'name': data['name'],
          'target': data['target_amount'] ?? data['target'],
        },
      );
      return SavingsGoalModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to update savings goal.';
      throw Exception(message);
    }
  }

  Future<SavingsGoalModel> deposit(int goalId, double amount) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.depositSavings(goalId),
        data: {'amount': amount},
      );
      return SavingsGoalModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to make deposit.';
      throw Exception(message);
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.savings}/$goalId');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to delete savings goal.';
      throw Exception(message);
    }
  }
}
