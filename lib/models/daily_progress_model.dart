class DailyProgressModel {
  final int? id;
  final int timeEntryId;
  final String date;
  final String? bathing;
  final String? mobility;
  final String? bedChair;
  final String? continence;
  final String? eating;
  final String? toileting;
  final String? dressing;
  final String? medication;

  DailyProgressModel({
    this.id,
    required this.timeEntryId,
    required this.date,
    this.bathing,
    this.mobility,
    this.bedChair,
    this.continence,
    this.eating,
    this.toileting,
    this.dressing,
    this.medication,
  });

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      id: json['id'],
      timeEntryId: json['time_entry_id'] ?? 0,
      date: json['date'] ?? '',
      bathing: json['bathing'],
      mobility: json['mobility'],
      bedChair: json['bed_chair'],
      continence: json['continence'],
      eating: json['eating'],
      toileting: json['toileting'],
      dressing: json['dressing'],
      medication: json['medication'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_entry_id': timeEntryId,
      'date': date,
      'bathing': bathing,
      'mobility': mobility,
      'bed_chair': bedChair,
      'continence': continence,
      'eating': eating,
      'toileting': toileting,
      'dressing': dressing,
      'medication': medication,
    };
  }
}