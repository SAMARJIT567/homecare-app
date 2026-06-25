class TimeEntryModel {
  final int? id;
  final int caregiverId;
  final int policyholderId;
  final String date;
  final String timeIn;
  final String? timeOut;
  final double? totalHours;
  final double? rate;
  final double? totalCharge;
  final String status;

  TimeEntryModel({
    this.id,
    required this.caregiverId,
    required this.policyholderId,
    required this.date,
    required this.timeIn,
    this.timeOut,
    this.totalHours,
    this.rate,
    this.totalCharge,
    this.status = 'active',
  });

  factory TimeEntryModel.fromJson(Map<String, dynamic> json) {
    return TimeEntryModel(
      id: json['id'],
      caregiverId: json['caregiver_id'] ?? 0,
      policyholderId: json['policyholder_id'] ?? 0,
      date: json['date'] ?? '',
      timeIn: json['time_in'] ?? '',
      timeOut: json['time_out'],
      totalHours: json['total_hours']?.toDouble(),
      rate: json['rate']?.toDouble(),
      totalCharge: json['total_charge']?.toDouble(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caregiver_id': caregiverId,
      'policyholder_id': policyholderId,
      'date': date,
      'time_in': timeIn,
      'time_out': timeOut,
      'total_hours': totalHours,
      'rate': rate,
      'total_charge': totalCharge,
      'status': status,
    };
  }
}