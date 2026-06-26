import 'package:dio/dio.dart';
import 'package:homecare_app/core/network/dio_client.dart';
import 'package:homecare_app/core/constants/api_endpoints.dart';
import 'package:homecare_app/models/response_model.dart';

class ApiService {
  final Dio _dio = DioClient.instance;
  final Dio _unAuthDio = DioClient.unAuthInstance;

  // Public getters
  Dio get dio => _dio;
  Dio get unAuthDio => _unAuthDio;

  // ============ AUTH ============
  Future<ResponseModel> login(String email, String password) async {
    try {
      print('🟡 API Service: Sending login request');
      print('📧 Email: $email');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.login)}');

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
      print('🔴 Request URL: ${e.requestOptions.uri}');
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
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.timeIn)}');

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
      print('🔴 Request URL: ${e.requestOptions.uri}');
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
      print('🟡 API Service: Sending timeOut request');
      print('⏰ Time Out: $timeOut');
      print('💰 Rate: $rate');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.timeOut)}');

      final response = await _dio.post(
        ApiEndpoints.timeOut,
        data: {
          'time_out': timeOut,
          'rate': rate,
        },
      );
      
      print('🟢 API Service: TimeOut response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: TimeOut error - ${e.message}');
      print('🔴 Request URL: ${e.requestOptions.uri}');
      return _handleError(e);
    }
  }

  Future<ResponseModel> getTodayLog(String date) async {
    try {
      print('🟡 API Service: Fetching today\'s log');
      print('📅 Date: $date');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.todayLog)}');

      final response = await _dio.get(
        ApiEndpoints.todayLog,
        queryParameters: {'date': date},
      );

      print('🟢 API Service: TodayLog response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: TodayLog error - ${e.message}');
      return _handleError(e);
    }
  }

  // ============ PROGRESS ============
  Future<ResponseModel> saveDailyProgress(Map<String, dynamic> data) async {
    try {
      print('🟡 API Service: Saving daily progress');
      print('📊 Data: $data');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.saveDaily)}');

      final response = await _dio.post(
        ApiEndpoints.saveDaily,
        data: data,
      );
      
      print('🟢 API Service: SaveDaily response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: SaveDaily error - ${e.message}');
      return _handleError(e);
    }
  }

  Future<ResponseModel> getDailyProgress(int timeEntryId) async {
    try {
      print('🟡 API Service: Fetching daily progress');
      print('🆔 Time Entry ID: $timeEntryId');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.getDaily)}');

      final response = await _dio.get(
        ApiEndpoints.getDaily,
        queryParameters: {'time_entry_id': timeEntryId},
      );

      print('🟢 API Service: GetDaily response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: GetDaily error - ${e.message}');
      return _handleError(e);
    }
  }

  // ============ REPORT ============
  Future<ResponseModel> generateReport(int timeEntryId) async {
    try {
      print('🟡 API Service: Generating report');
      print('🆔 Time Entry ID: $timeEntryId');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.generateReport)}');

      final response = await _dio.post(
        ApiEndpoints.generateReport,
        data: {'time_entry_id': timeEntryId},
      );

      print('🟢 API Service: GenerateReport response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: GenerateReport error - ${e.message}');
      return _handleError(e);
    }
  }

  Future<ResponseModel> getReport(int timeEntryId) async {
    try {
      print('🟡 API Service: Fetching report');
      print('🆔 Time Entry ID: $timeEntryId');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.getReport)}');

      final response = await _dio.get(
        ApiEndpoints.getReport,
        queryParameters: {'entry_id': timeEntryId},
      );

      print('🟢 API Service: GetReport response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: GetReport error - ${e.message}');
      return _handleError(e);
    }
  }

  // ============ SIGNATURE ============
  Future<ResponseModel> saveSignature(Map<String, dynamic> data) async {
    try {
      print('🟡 API Service: Saving signature');
      print('📊 Data: $data');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.saveSignature)}');

      final response = await _dio.post(
        ApiEndpoints.saveSignature,
        data: data,
      );

      print('🟢 API Service: SaveSignature response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: SaveSignature error - ${e.message}');
      return _handleError(e);
    }
  }

  Future<ResponseModel> getSignature(int timeEntryId) async {
    try {
      print('🟡 API Service: Fetching signatures for entry: $timeEntryId');
      print('🔗 URL: ${ApiEndpoints.getFullUrl(ApiEndpoints.getSignature)}');

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

  // ============ ADMIN APIs ============
  // ✅ Add admin-specific APIs with debug logs
  Future<ResponseModel> adminLogin(String email, String password) async {
    try {
      print('🟡 API Service: Admin login request');
      print('📧 Email: $email');
      print('🔗 URL: ${ApiEndpoints.getFullUrl('api/admin/login.php')}');

      final response = await _unAuthDio.post(
        'api/admin/login.php',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      print('🟢 API Service: Admin login response received');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔴 API Service: Admin login error - ${e.message}');
      print('🔴 Request URL: ${e.requestOptions.uri}');
      return _handleError(e);
    }
  }

  // ============ ERROR HANDLER ============
  ResponseModel _handleError(DioException error) {
    String message = 'Something went wrong';

    print('🔴 ========== ERROR DETAILS ==========');
    print('🔴 Error Type: ${error.type}');
    print('🔴 Error Message: ${error.message}');
    print('🔴 Request URL: ${error.requestOptions.uri}');
    print('🔴 Request Method: ${error.requestOptions.method}');
    print('🔴 Request Headers: ${error.requestOptions.headers}');
    print('🔴 Request Data: ${error.requestOptions.data}');
    
    if (error.response != null) {
      print('🔴 Response Status: ${error.response?.statusCode}');
      print('🔴 Response Data: ${error.response?.data}');
      print('🔴 Response Headers: ${error.response?.headers}');
      
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

    print('🔴 Final Error Message: $message');
    print('🔴 =====================================');

    return ResponseModel(
      status: false,
      message: message,
      data: null,
    );
  }
}