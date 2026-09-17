import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<List<TransactionModel>> getTransactions({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.get(
        ApiEndpoints.transactions,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      if (response.data is List) {
        return (response.data as List).map((e) => TransactionModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load transactions.';
      throw Exception(message);
    }
  }

  Future<TransactionModel> addTransaction(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.transactions,
        data: {
          'name': data['name'],
          'category': data['category'],
          'amount': data['amount'],
          'payment_status': data['payment_status'],
          'when': data['when'],
        },
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to add transaction.';
      throw Exception(message);
    }
  }

  Future<TransactionModel> updateTransaction(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.transactionDetails(id),
        data: {
          'name': data['name'],
          'category': data['category'],
          'amount': data['amount'],
          'payment_status': data['payment_status'],
          'when': data['when'],
        },
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to update transaction.';
      throw Exception(message);
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.transactionDetails(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to delete transaction.';
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>>> getBudgets({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.get(
        ApiEndpoints.budgets,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load budgets.';
      throw Exception(message);
    }
  }

  Future<bool> updateBudgets(Map<String, double> budgets) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.budgets,
        data: budgets,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to update budgets.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getStatement(
    String period, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};
      if (startDate != null) queryParams['start_date_str'] = startDate;
      if (endDate != null) queryParams['end_date_str'] = endDate;

      final response = await _apiClient.get(
        '/api/transactions/statement',
        queryParameters: queryParams,
      );
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to fetch statement.';
      throw Exception(message);
    }
  }
}
