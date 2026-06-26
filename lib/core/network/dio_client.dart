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
        },
        // ✅ Add these options for better HTTP handling
        validateStatus: (status) {
          return status != null && status < 500;
        },
        followRedirects: true,
        maxRedirects: 5,
        // ✅ For HTTP (not HTTPS), we don't need SSL verification
        // If using HTTPS with self-signed certificate, uncomment below
        // 
        // For development with self-signed certificates only:
        // 
        // if (kDebugMode) {
        //   (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        //       (HttpClient client) {
        //     client.badCertificateCallback =
        //         (X509Certificate cert, String host, int port) => true;
        //     return client;
        //   };
        // }
      ),
    );

    // ✅ Add interceptors
    if (withAuth) {
      dio.interceptors.add(AuthInterceptor());
    }
    dio.interceptors.add(LoggingInterceptor());

    // ✅ Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // ✅ Handle CORS errors gracefully
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown) {
            // Check if it's a CORS issue
            if (error.message?.contains('CORS') == true ||
                error.message?.contains('Access-Control-Allow-Origin') == true) {
              debugPrint('🔴 CORS Error detected: ${error.message}');
            }
          }
          handler.next(error);
        },
      ),
    );

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

  // ✅ Get Dio instance with custom headers (for debugging)
  static Dio get debugInstance {
    final dio = _createDio(withAuth: false);
    dio.options.headers['X-Debug'] = 'true';
    return dio;
  }
}