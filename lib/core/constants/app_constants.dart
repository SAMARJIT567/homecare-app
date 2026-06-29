class AppConstants {
  static const String appName = 'Absolute Choice Homecare';
  static const String baseUrl = 'http://43.205.243.18/flutter_backend/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // ADL Values
  static const List<String> adlLevels = ['I', 'S', 'A', 'H'];
  static const Map<String, String> adlLevelMap = {
    'I': 'Independent',
    'S': 'Supervision',
    'A': 'Stand-by Assistance',
    'H': 'Hands On Assistance'
  };
}