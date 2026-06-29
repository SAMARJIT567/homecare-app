import 'app_constants.dart';

class ApiEndpoints {
  // Auth
  static const String login = 'api/auth/login.php';
  static const String logout = 'api/auth/logout.php';

  // Time
  static const String timeIn = 'api/time/time_in.php';
  static const String timeOut = 'api/time/time_out.php';
  static const String todayLog = 'api/time/today_log.php';

  // Progress
  static const String saveDaily = 'api/progress/save_daily.php';
  static const String getDaily = 'api/progress/get_daily.php';

  // Report
  static const String generateReport = 'api/report/generate.php';
  static const String getReport = 'api/report/get.php';

  // Signature
  static const String saveSignature = 'api/signature/save.php';
  static const String getSignature = 'api/signature/get.php';

  // Policyholders for caregivers
  static const String policyholdersList = 'api/policyholders/list.php';

  // Full URLs with proper encoding
  static String getFullUrl(String endpoint) {
    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl
        : '${AppConstants.baseUrl}/';
    return '$base$endpoint';
  }

  // Proxy URL for CORS (if needed)
  static String getProxyUrl(String endpoint) {
    return getFullUrl(endpoint);
  }

  // Get URL with query parameters
  static String getUrlWithParams(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse(getFullUrl(endpoint));
    final newUri = uri.replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    return newUri.toString();
  }
}