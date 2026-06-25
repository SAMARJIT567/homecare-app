import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:homecare_app/core/constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  // ✅ Create a new Dio instance each time to avoid interceptor conflicts
  static Dio _createDio({bool withAuth = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // ✅ Add this for CORS
          'Origin': 'http://localhost:64891',
        },
        // ✅ Add these options for better CORS handling
        validateStatus: (status) {
          return status != null && status < 500;
        },
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    // ✅ Add interceptors
    if (withAuth) {
      dio.interceptors.add(AuthInterceptor());
    }
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }

  // ✅ Get authenticated Dio instance
  static Dio get instance {
    return _createDio(withAuth: true);
  }

  // ✅ Get unauthenticated Dio instance (for login, etc.)
  static Dio get unAuthInstance {
    return _createDio(withAuth: false);
  }
}