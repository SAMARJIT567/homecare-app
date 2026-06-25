class SignatureModel {
  final int? id;
  final int timeEntryId;
  final String caregiverSignature;
  final String policyholderSignature;
  final String? caregiverSignedDate;
  final String? policyholderSignedDate;

  SignatureModel({
    this.id,
    required this.timeEntryId,
    required this.caregiverSignature,
    required this.policyholderSignature,
    this.caregiverSignedDate,
    this.policyholderSignedDate,
  });

  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'],
      timeEntryId: json['time_entry_id'] ?? 0,
      caregiverSignature: json['caregiver_signature'] ?? '',
      policyholderSignature: json['policyholder_signature'] ?? '',
      caregiverSignedDate: json['caregiver_signed_date'],
      policyholderSignedDate: json['policyholder_signed_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_entry_id': timeEntryId,
      'caregiver_signature': caregiverSignature,
      'policyholder_signature': policyholderSignature,
    };
  }
}