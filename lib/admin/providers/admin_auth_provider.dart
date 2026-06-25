import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/core/constants/admin_api_endpoints.dart';
import 'package:homecare_app/admin/models/admin_models.dart';

class AdminAuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AdminUser? _adminUser;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AdminUser? get adminUser => _adminUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AdminAuthProvider() {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('admin_token');

      if (_token != null && _token!.isNotEmpty) {
        final role = prefs.getString('admin_role') ?? '';

        if (role == 'admin') {
          _isAuthenticated = true;
          _adminUser = AdminUser(
            id: prefs.getInt('admin_id') ?? 0,
            name: prefs.getString('admin_name') ?? '',
            email: prefs.getString('admin_email') ?? '',
            role: role,
          );
          print('✅ AdminAuthProvider: Loaded admin: ${_adminUser?.name}');
        } else {
          print('🟡 AdminAuthProvider: Invalid role "$role", clearing data');
          _token = null;
          await prefs.remove('admin_token');
          await prefs.remove('admin_id');
          await prefs.remove('admin_name');
          await prefs.remove('admin_email');
          await prefs.remove('admin_role');
        }
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    print('🟡 AdminAuthProvider: Login attempt for: $email');

    try {
      final response = await _apiService.unAuthDio.post(
        AdminApiEndpoints.getFullUrl(AdminApiEndpoints.adminLogin),
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      print('🟢 AdminAuthProvider: Response status: ${data['status']}');

      if (data['status'] == true) {
        final userData = data['data']['user'];
        final role = userData['role'] ?? 'admin';

        if (role != 'admin') {
          print('🔴 AdminAuthProvider: User is not admin');
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': 'Unauthorized - Admin access only'};
        }

        _adminUser = AdminUser(
          id: userData['id'] ?? 0,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: role,
        );
        _token = data['data']['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('user_role');

        await prefs.setString('admin_token', _token!);
        await prefs.setInt('admin_id', _adminUser!.id);
        await prefs.setString('admin_name', _adminUser!.name);
        await prefs.setString('admin_email', _adminUser!.email);
        await prefs.setString('admin_role', _adminUser!.role);

        _isLoading = false;
        notifyListeners();
        print('✅ AdminAuthProvider: Admin login successful: ${_adminUser?.name}');
        return {'success': true, 'data': data['data']};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('🔴 AdminAuthProvider: Error: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_id');
    await prefs.remove('admin_name');
    await prefs.remove('admin_email');
    await prefs.remove('admin_role');

    _adminUser = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
    print('✅ AdminAuthProvider: Admin logged out');
  }
}