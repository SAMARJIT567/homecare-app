import 'app_constants.dart';

class AdminApiEndpoints {
  // Admin Auth
  static const String adminLogin = 'api/admin/login.php';

  // Admin Dashboard
  static const String dashboard = 'api/admin/dashboard.php';
  static const String stats = 'api/admin/stats.php';

  // Admin Management
  static const String caregivers = 'api/admin/caregivers.php';
  static const String policyholders = 'api/admin/policyholders.php';
  static const String shifts = 'api/admin/shifts.php';
  static const String approveShift = 'api/admin/approve_shift.php';

  static String getFullUrl(String endpoint) {
    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl
        : '${AppConstants.baseUrl}/';
    return '$base$endpoint';
  }
}