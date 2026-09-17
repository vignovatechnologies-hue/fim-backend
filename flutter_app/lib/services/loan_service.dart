import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/loan_model.dart';

class LoanService {
  final ApiClient _apiClient;

  LoanService(this._apiClient);

  Future<List<LoanModel>> getLoans() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.loans);
      if (response.data is List) {
        return (response.data as List).map((e) => LoanModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to load loans.';
      throw Exception(message);
    }
  }

  Future<LoanModel> addLoan(Map<String, dynamic> loanData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.loans,
        data: {
          'name': loanData['name'],
          'type': loanData['type'],
          'emi': loanData['emi'],
          'rate': loanData['rate'],
          'due_day': loanData['due_day'],
          'left_amount': loanData['left_amount'],
          'total_tenure': loanData['total_tenure'],
          'paid_tenure': loanData['paid_tenure'] ?? 0,
        },
      );
      return LoanModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to add loan.';
      throw Exception(message);
    }
  }

  Future<bool> deleteLoan(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.loanDetails(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to delete loan.';
      throw Exception(message);
    }
  }

  Future<LoanModel> payLoan(int id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.payLoan(id));
      return LoanModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to mark loan as paid.';
      throw Exception(message);
    }
  }

  Future<LoanModel> unpayLoan(int id) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.unpayLoan(id));
      return LoanModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Failed to revert payment status.';
      throw Exception(message);
    }
  }
}
