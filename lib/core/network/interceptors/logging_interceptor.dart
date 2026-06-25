import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🔵 REQUEST: ${options.method} ${options.path}');
    debugPrint('🔵 HEADERS: ${options.headers}');
    debugPrint('🔵 DATA: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('🟢 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    debugPrint('🟢 DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('🔴 ERROR: ${err.message}');
    debugPrint('🔴 RESPONSE: ${err.response?.data}');
    super.onError(err, handler);
  }
}