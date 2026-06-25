import 'package:dio/dio.dart';
import 'package:homecare_app/core/network/dio_client.dart';
import 'package:homecare_app/core/constants/api_endpoints.dart';
import 'package:homecare_app/models/response_model.dart';

class ApiService {
  final Dio _dio = DioClient.instance;
  final Dio _unAuthDio = DioClient.unAuthInstance;

  // ✅ Add public getters
  Dio get dio => _dio;
  Dio get unAuthDio => _unAuthDio;

  // ============ AUTH ============
  Future<ResponseModel> login(String email, String password) async {
    try {
      print('🟡 API Service: Sending login request');
      print('📧 Email: $email');

      final response = await _unAuthDio.post(
        ApiEndpoints.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      print('🟢 API Service: Response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: DioException caught');
      print('🔴 Error Type: ${e.type}');
      print('🔴 Error Message: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return _handleError(e);
    } catch (e) {
      print('🔴 API Service: Unknown error: $e');
      return ResponseModel(
        status: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<ResponseModel> logout() async {
    try {
      final response = await _dio.post(ApiEndpoints.logout);
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ============ TIME ============
  Future<ResponseModel> timeIn(int policyholderId, String date, String timeIn) async {
    try {
      print('🟡 API Service: Sending timeIn request');
      print('📋 Policyholder ID: $policyholderId');
      print('📅 Date: $date');
      print('⏰ Time: $timeIn');

      final response = await _dio.post(
        ApiEndpoints.timeIn,
        data: {
          'policyholder_id': policyholderId,
          'date': date,
          'time_in': timeIn,
        },
      );

      print('🟢 API Service: TimeIn response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: DioException - ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      return _handleError(e);
    } catch (e) {
      print('🔴 API Service: Unknown error - $e');
      return ResponseModel(
        status: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<ResponseModel> timeOut(String timeOut, double rate) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.timeOut,
        data: {
          'time_out': timeOut,
          'rate': rate,
        },
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseModel> getTodayLog(String date) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.todayLog,
        queryParameters: {'date': date},
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ============ PROGRESS ============
  Future<ResponseModel> saveDailyProgress(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.saveDaily,
        data: data,
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseModel> getDailyProgress(int timeEntryId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getDaily,
        queryParameters: {'time_entry_id': timeEntryId},
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ============ REPORT ============
  Future<ResponseModel> generateReport(int timeEntryId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.generateReport,
        data: {'time_entry_id': timeEntryId},
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseModel> getReport(int timeEntryId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getReport,
        queryParameters: {'entry_id': timeEntryId},
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ============ SIGNATURE ============
  Future<ResponseModel> saveSignature(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.saveSignature,
        data: data,
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseModel> getSignature(int timeEntryId) async {
    try {
      print('🟡 API Service: Fetching signatures for entry: $timeEntryId');

      final response = await _dio.get(
        ApiEndpoints.getSignature,
        queryParameters: {'time_entry_id': timeEntryId},
      );

      print('🟢 API Service: GetSignature response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: GetSignature error - ${e.message}');
      return _handleError(e);
    }
  }

  // ============ ERROR HANDLER ============
  ResponseModel _handleError(DioException error) {
    String message = 'Something went wrong';

    if (error.response != null) {
      try {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'] as String;
        } else if (data is String) {
          message = data;
        } else {
          message = error.response?.statusMessage ?? 'Server error';
        }
      } catch (e) {
        message = 'Server error: ${error.response?.statusCode}';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection. Please check your network.';
    } else if (error.type == DioExceptionType.unknown) {
      if (error.message != null &&
          (error.message!.contains('CORS') ||
              error.message!.contains('Access-Control-Allow-Origin'))) {
        message = 'CORS error. Please check server configuration.';
      } else {
        message = error.message ?? 'Unknown network error';
      }
    } else {
      message = error.message ?? 'Unknown error occurred';
    }

    return ResponseModel(
      status: false,
      message: message,
      data: null,
    );
  }
}