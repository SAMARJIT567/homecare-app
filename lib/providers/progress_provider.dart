import 'package:flutter/material.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/models/response_model.dart';
import 'package:homecare_app/models/daily_progress_model.dart';
import 'package:homecare_app/models/iadl_model.dart';

class ProgressProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  DailyProgressModel? _dailyProgress;
  IADLModel? _iadls;

  bool get isLoading => _isLoading;
  DailyProgressModel? get dailyProgress => _dailyProgress;
  IADLModel? get iadls => _iadls;

  Future<ResponseModel> saveProgress({
    required int timeEntryId,
    required String date,
    Map<String, String?>? adls,
    Map<String, bool>? iadls,
  }) async {
    _isLoading = true;
    notifyListeners();

    final data = {
      'time_entry_id': timeEntryId,
      'date': date,
      ...?adls,
      ...?iadls?.map((key, value) => MapEntry(key, value ? 1 : 0)),
    };

    final response = await _apiService.saveDailyProgress(data);

    if (response.status) {
      if (adls != null) {
        _dailyProgress = DailyProgressModel(
          timeEntryId: timeEntryId,
          date: date,
          bathing: adls['bathing'],
          mobility: adls['mobility'],
          bedChair: adls['bed_chair'],
          continence: adls['continence'],
          eating: adls['eating'],
          toileting: adls['toileting'],
          dressing: adls['dressing'],
          medication: adls['medication'],
        );
      }
      if (iadls != null) {
        _iadls = IADLModel(
          timeEntryId: timeEntryId,
          date: date,
          housekeeping: iadls['housekeeping'] ?? false,
          mealPrep: iadls['meal_prep'] ?? false,
          shopping: iadls['shopping'] ?? false,
          transportation: iadls['transportation'] ?? false,
          managingMedicines: iadls['managing_medicines'] ?? false,
          laundry: iadls['laundry'] ?? false,
        );
      }
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ResponseModel> getProgress(int timeEntryId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.getDailyProgress(timeEntryId);

    if (response.status && response.data != null) {
      final data = response.data;
      if (data['adls'] != null) {
        _dailyProgress = DailyProgressModel.fromJson(data['adls']);
      }
      if (data['iadls'] != null) {
        _iadls = IADLModel.fromJson(data['iadls']);
      }
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  void reset() {
    _dailyProgress = null;
    _iadls = null;
    notifyListeners();
  }
}