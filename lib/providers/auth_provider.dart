import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecare_app/core/constants/app_constants.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/models/response_model.dart';
import 'package:homecare_app/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);

      if (_token != null && _token!.isNotEmpty) {
        final role = prefs.getString('user_role') ?? '';

        // ✅ Only load if role is caregiver, NOT admin
        if (role == 'caregiver') {
          _isAuthenticated = true;
          _user = UserModel(
            id: prefs.getInt(AppConstants.userIdKey) ?? 0,
            name: prefs.getString(AppConstants.userNameKey) ?? '',
            email: prefs.getString(AppConstants.userEmailKey) ?? '',
          );
          print('✅ AuthProvider: Loaded caregiver: ${_user?.name}');
        } else {
          // ✅ If role is admin or empty, clear caregiver data
          print('🟡 AuthProvider: Role is "$role", clearing caregiver data');
          _token = null;
          _isAuthenticated = false;
          _user = null;

          // ✅ Clear caregiver storage
          await prefs.remove(AppConstants.tokenKey);
          await prefs.remove(AppConstants.userIdKey);
          await prefs.remove(AppConstants.userNameKey);
          await prefs.remove(AppConstants.userEmailKey);
          await prefs.remove('user_role');
        }
      } else {
        print('🟡 AuthProvider: No token found');
      }
    } catch (e) {
      print('🔴 AuthProvider: Error loading saved data: $e');
    }
    notifyListeners();
  }

  Future<ResponseModel> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    print('🟡 AuthProvider: Login called for: $email');

    try {
      final response = await _apiService.login(email, password);

      print('🟢 AuthProvider: Response status: ${response.status}');
      print('📝 Message: ${response.message}');

      if (response.status && response.data != null) {
        try {
          final userData = response.data['user'] as Map<String, dynamic>;
          final role = userData['role'] as String? ?? 'caregiver';

          // ✅ Only allow caregiver login (NOT admin)
          if (role == 'admin') {
            print('🔴 AuthProvider: Admin user cannot login as caregiver');
            _isLoading = false;
            notifyListeners();
            return ResponseModel(
              status: false,
              message: 'Please use "Admin Login" button for admin accounts',
              data: null,
            );
          }

          _user = UserModel.fromJson(userData);
          _token = response.data['token'] as String;
          _isAuthenticated = true;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.tokenKey, _token!);
          await prefs.setInt(AppConstants.userIdKey, _user!.id);
          await prefs.setString(AppConstants.userNameKey, _user!.name);
          await prefs.setString(AppConstants.userEmailKey, _user!.email);
          await prefs.setString('user_role', role);

          print('✅ AuthProvider: Caregiver login successful: ${_user!.name}');
        } catch (e) {
          print('🔴 AuthProvider: Error parsing data: $e');
          _isAuthenticated = false;
        }
      } else {
        print('🔴 AuthProvider: Login failed - ${response.message}');
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print('🔴 AuthProvider: Exception: $e');
      _isLoading = false;
      notifyListeners();
      return ResponseModel(
        status: false,
        message: 'Login error: $e',
        data: null,
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove('user_role');

    _user = null;
    _token = null;
    _isAuthenticated = false;

    notifyListeners();
    print('✅ AuthProvider: Logged out');
  }
}