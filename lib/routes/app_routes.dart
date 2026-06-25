import 'package:flutter/material.dart';
import 'package:homecare_app/screens/auth/login_screen.dart';
import 'package:homecare_app/screens/home/home_screen.dart';
import 'package:homecare_app/screens/time/time_in_screen.dart';
import 'package:homecare_app/screens/time/time_out_screen.dart';
import 'package:homecare_app/screens/progress/daily_progress_screen.dart';
import 'package:homecare_app/screens/report/weekly_report_screen.dart';
import 'package:homecare_app/screens/report/report_preview_screen.dart';
import 'package:homecare_app/screens/signature/signature_screen.dart';
import 'package:homecare_app/screens/signature/signature_preview.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String timeIn = '/time-in';
  static const String timeOut = '/time-out';
  static const String dailyProgress = '/daily-progress';
  static const String weeklyReport = '/weekly-report';
  static const String reportPreview = '/report-preview';
  static const String signature = '/signature';
  static const String signaturePreview = '/signature-preview';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case timeIn:
        return MaterialPageRoute(builder: (_) => const TimeInScreen());
      case timeOut:
        return MaterialPageRoute(builder: (_) => const TimeOutScreen());
      case dailyProgress:
        return MaterialPageRoute(builder: (_) => const DailyProgressScreen());
      case weeklyReport:
        return MaterialPageRoute(builder: (_) => const WeeklyReportScreen());
      case reportPreview:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportPreviewScreen(reportData: args?['reportData']),
        );
      case signature:
        return MaterialPageRoute(builder: (_) => const SignatureScreen());
      case signaturePreview:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SignaturePreviewScreen(
            caregiverSignature: args?['caregiverSignature'],
            policyholderSignature: args?['policyholderSignature'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}