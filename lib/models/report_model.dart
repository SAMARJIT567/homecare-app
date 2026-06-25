class ReportModel {
  final Map<String, dynamic>? policyholder;
  final Map<String, dynamic>? caregiver;
  final String? dateOfService;
  final String? timeIn;
  final String? timeOut;
  final double? totalHours;
  final double? rate;
  final double? totalCharge;
  final Map<String, dynamic>? adls;
  final Map<String, dynamic>? iadls;
  final Map<String, dynamic>? signatures;
  final String? certification;

  ReportModel({
    this.policyholder,
    this.caregiver,
    this.dateOfService,
    this.timeIn,
    this.timeOut,
    this.totalHours,
    this.rate,
    this.totalCharge,
    this.adls,
    this.iadls,
    this.signatures,
    this.certification,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // ✅ Helper function to convert String to double safely
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ReportModel(
      policyholder: json['policyholder'] as Map<String, dynamic>?,
      caregiver: json['caregiver'] as Map<String, dynamic>?,
      dateOfService: json['date_of_service'] as String?,
      timeIn: json['time_in'] as String?,
      timeOut: json['time_out'] as String?,
      totalHours: _parseDouble(json['total_hours']),
      rate: _parseDouble(json['rate']),
      totalCharge: _parseDouble(json['total_charge']),
      adls: json['adls'] as Map<String, dynamic>?,
      iadls: json['iadls'] as Map<String, dynamic>?,
      signatures: json['signatures'] as Map<String, dynamic>?,
      certification: json['certification'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policyholder': policyholder,
      'caregiver': caregiver,
      'date_of_service': dateOfService,
      'time_in': timeIn,
      'time_out': timeOut,
      'total_hours': totalHours,
      'rate': rate,
      'total_charge': totalCharge,
      'adls': adls,
      'iadls': iadls,
      'signatures': signatures,
      'certification': certification,
    };
  }
}