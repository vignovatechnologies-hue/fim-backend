import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class InsightsService {
  final ApiClient _apiClient;

  InsightsService(this._apiClient);

  Future<List<dynamic>> getAiAnalysis() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.insights);
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load insights.';
      throw Exception(message);
    }
  }

  Future<String> askAi(String question) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.insightsAsk,
        data: {'text': question},
      );
      return response.data?['text'] ?? 'No answer received.';
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to communicate with AI Assistant.';
      throw Exception(message);
    }
  }
}
