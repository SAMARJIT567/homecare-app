import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String date, {String format = 'yyyy-MM-dd'}) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat(format).format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  static String formatTime(String time, {String format = 'hh:mm a'}) {
    try {
      final parsedTime = DateFormat('HH:mm').parse(time);
      return DateFormat(format).format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  static String formatDateTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  static String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  static String getCurrentDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  static String getWeekStartDate({String format = 'yyyy-MM-dd'}) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return DateFormat(format).format(weekStart);
  }

  static String getWeekEndDate({String format = 'yyyy-MM-dd'}) {
    final now = DateTime.now();
    final weekEnd = now.add(Duration(days: 7 - now.weekday));
    return DateFormat(format).format(weekEnd);
  }

  static List<String> getWeekDays({String format = 'yyyy-MM-dd'}) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final days = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      days.add(DateFormat(format).format(day));
    }
    return days;
  }

  static String getDayName(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('EEEE').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  static bool isToday(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      final today = DateTime.now();
      return parsedDate.year == today.year &&
          parsedDate.month == today.month &&
          parsedDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours h $remainingMinutes m';
    }
    return '$remainingMinutes m';
  }
}