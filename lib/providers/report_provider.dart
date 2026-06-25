import 'package:flutter/material.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/models/response_model.dart';
import 'package:homecare_app/models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  ReportModel? _report;

  bool get isLoading => _isLoading;
  ReportModel? get report => _report;

  Future<ResponseModel> generateReport(int timeEntryId) async {
    _isLoading = true;
    notifyListeners();

    print('🟡 ReportProvider: Generating report for entry: $timeEntryId');

    try {
      if (timeEntryId <= 0) {
        print('🔴 Invalid timeEntryId: $timeEntryId');
        _isLoading = false;
        notifyListeners();
        return ResponseModel(
          status: false,
          message: 'Invalid time entry ID',
          data: null,
        );
      }

      final response = await _apiService.generateReport(timeEntryId);

      print('🟢 ReportProvider: Response received');
      print('📊 Status: ${response.status}');
      print('📝 Message: ${response.message}');

      if (response.status && response.data != null) {
        try {
          _report = ReportModel.fromJson(response.data);
          print('✅ Report generated successfully');
        } catch (e) {
          print('🔴 Error parsing report data: $e');
          _isLoading = false;
          notifyListeners();
          return ResponseModel(
            status: false,
            message: 'Error parsing report: $e',
            data: null,
          );
        }
      } else {
        print('🔴 Report generation failed: ${response.message}');
      }

      _isLoading = false;
      notifyListeners();
      return response;

    } catch (e) {
      print('🔴 ReportProvider Exception: $e');
      _isLoading = false;
      notifyListeners();
      return ResponseModel(
        status: false,
        message: 'Error generating report: $e',
        data: null,
      );
    }
  }

  Future<ResponseModel> getReport(int timeEntryId) async {
    _isLoading = true;
    notifyListeners();

    print('🟡 ReportProvider: Fetching report for entry: $timeEntryId');

    try {
      final response = await _apiService.getReport(timeEntryId);

      print('🟢 ReportProvider: Response received');
      print('📊 Status: ${response.status}');

      if (response.status && response.data != null) {
        try {
          _report = ReportModel.fromJson(response.data);
          print('✅ Report fetched successfully');
        } catch (e) {
          print('🔴 Error parsing report data: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      return response;

    } catch (e) {
      print('🔴 ReportProvider Exception: $e');
      _isLoading = false;
      notifyListeners();
      return ResponseModel(
        status: false,
        message: 'Error fetching report: $e',
        data: null,
      );
    }
  }

  void reset() {
    _report = null;
    notifyListeners();
  }
}