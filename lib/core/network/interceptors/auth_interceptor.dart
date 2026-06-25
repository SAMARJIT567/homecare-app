import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecare_app/core/constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    // Add CORS headers if needed
    options.headers['Access-Control-Allow-Origin'] = '*';

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add Origin header for web
    if (options.extra['fromWeb'] == true) {
      options.headers['Origin'] = 'http://localhost:64891';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token expiration
    if (err.response?.statusCode == 401) {
      _handleTokenExpired();
    }

    // Handle CORS errors
    if (err.type == DioExceptionType.connectionError &&
        err.message?.contains('CORS') == true) {
      debugPrint('🔴 CORS Error in AuthInterceptor: ${err.message}');

      // Try without auth if CORS issue
      if (err.requestOptions.headers.containsKey('Authorization')) {
        err.requestOptions.headers.remove('Authorization');

        // Retry the request without auth
        _retryWithoutAuth(err, handler);
        return;
      }
    }

    super.onError(err, handler);
  }

  // Separate method for retry logic
  void _retryWithoutAuth(DioException err, ErrorInterceptorHandler handler) {
    try {
      // Create new Dio instance
      final dio = Dio();

      // Fetch with modified options
      dio.fetch(err.requestOptions).then((response) {
        handler.resolve(response);
      }).catchError((error) {
        debugPrint('🔴 Retry failed: $error');
        handler.next(err);
      });
    } catch (e) {
      debugPrint('🔴 Retry exception: $e');
      handler.next(err);
    }
  }

  void _handleTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate to login - handled in main.dart
  }
}