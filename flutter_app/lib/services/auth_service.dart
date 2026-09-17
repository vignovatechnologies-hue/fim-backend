import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  String _parseDioError(DioException e, String fallback) {
    // 1. Dynamic Network / Connectivity Check
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.response == null) {
      return 'Network Error: Unable to connect to server. Please check your internet data connection and try again.';
    }

    // 2. Dynamic Backend Error Response Data Extraction
    final data = e.response?.data;
    if (data != null) {
      if (data is Map<String, dynamic>) {
        if (data['detail'] != null && data['detail'].toString().trim().isNotEmpty) {
          return data['detail'].toString().trim();
        } else if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          return data['message'].toString().trim();
        } else if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
          return data['error'].toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
    }

    // 3. Dynamic Status Code Fallbacks
    final statusCode = e.response?.statusCode;
    if (statusCode == 400 || statusCode == 401) {
      return 'Incorrect credentials. Please verify your email and password.';
    } else if (statusCode == 404) {
      return 'No account found for this email address. Please sign up.';
    } else if (statusCode != null && statusCode >= 500) {
      return 'Server Error ($statusCode). Please try again later.';
    }

    return fallback;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.signin,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['access_token'] != null) {
        final token = data['access_token'] as String;
        await _storageService.saveToken(token);

        if (data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          await _storageService.saveUserData(jsonEncode(user.toJson()));
          return {'success': true, 'token': token, 'user': user};
        }
      }
      return {'success': true, 'data': data};
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Login failed. Please check credentials.'));
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.signup,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone?.trim(),
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Registration failed.'));
    }
  }

  Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verify,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Verification code invalid or expired.'));
    }
  }

  Future<bool> resendCode({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resend,
        data: {'email': email.trim().toLowerCase()},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Failed to resend code.'));
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestReset,
        data: {'email': email.trim().toLowerCase()},
      );
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Password reset request failed.'));
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.reset,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
          'new_password': newPassword,
        },
      );
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Failed to reset password.'));
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
