import 'package:flutter/material.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/models/response_model.dart';
import 'package:homecare_app/models/signature_model.dart';

class SignatureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  SignatureModel? _signature;

  bool get isLoading => _isLoading;
  SignatureModel? get signature => _signature;

  Future<ResponseModel> saveSignature({
    required int timeEntryId,
    required String caregiverSignature,
    required String policyholderSignature,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.saveSignature({
      'time_entry_id': timeEntryId,
      'caregiver_signature': caregiverSignature,
      'policyholder_signature': policyholderSignature,
    });

    if (response.status) {
      _signature = SignatureModel(
        timeEntryId: timeEntryId,
        caregiverSignature: caregiverSignature,
        policyholderSignature: policyholderSignature,
      );
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ResponseModel> getSignature(int timeEntryId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.getSignature(timeEntryId);

    if (response.status && response.data != null) {
      _signature = SignatureModel.fromJson(response.data);
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  void reset() {
    _signature = null;
    notifyListeners();
  }
}