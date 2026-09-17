import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardStatsModel> getSummary() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardSummary);
      if (response.data != null && response.data is Map<String, dynamic>) {
        return DashboardStatsModel.fromJson(response.data);
      }
      return DashboardStatsModel();
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load dashboard summary.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardStats);
      return response.data ?? {};
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load dashboard stats.';
      throw Exception(message);
    }
  }
}
