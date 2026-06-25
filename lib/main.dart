import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/auth_provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/progress_provider.dart';
import 'package:homecare_app/providers/report_provider.dart';
import 'package:homecare_app/providers/signature_provider.dart';
import 'package:homecare_app/admin/providers/admin_auth_provider.dart';
import 'package:homecare_app/admin/providers/admin_data_provider.dart';
import 'package:homecare_app/screens/auth/login_screen.dart';
import 'package:homecare_app/screens/home/home_screen.dart';
import 'package:homecare_app/admin/screens/admin_login_screen.dart';
import 'package:homecare_app/admin/screens/admin_dashboard_screen.dart';
import 'package:homecare_app/core/utils/connectivity_checker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TimeProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SignatureProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminDataProvider()),
      ],
      child: MaterialApp(
        title: 'Homecare App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const ConnectivityChecker(
            child: AuthWrapper(),
          ),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get both providers
    final authProvider = Provider.of<AuthProvider>(context);
    final adminAuthProvider = Provider.of<AdminAuthProvider>(context);

    // ✅ Debug - Print current state
    print('🟡 AuthWrapper: adminAuthProvider.isAuthenticated = ${adminAuthProvider.isAuthenticated}');
    print('🟡 AuthWrapper: authProvider.isAuthenticated = ${authProvider.isAuthenticated}');

    // ✅ Check loading states first
    if (authProvider.isLoading || adminAuthProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ CRITICAL: Check admin FIRST
    if (adminAuthProvider.isAuthenticated) {
      print('🟢 AuthWrapper: Redirecting to Admin Dashboard');
      return const AdminDashboardScreen();
    }

    // ✅ Then check caregiver
    if (authProvider.isAuthenticated) {
      print('🟢 AuthWrapper: Redirecting to Caregiver Home');
      return const HomeScreen();
    }

    // ✅ Show login screen if neither is authenticated
    print('🟡 AuthWrapper: Showing Login Screen');
    return const LoginScreen();
  }
}