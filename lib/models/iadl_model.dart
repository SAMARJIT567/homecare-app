class IADLModel {
  final int? id;
  final int timeEntryId;
  final String date;
  final bool housekeeping;
  final bool mealPrep;
  final bool shopping;
  final bool transportation;
  final bool managingMedicines;
  final bool laundry;

  IADLModel({
    this.id,
    required this.timeEntryId,
    required this.date,
    this.housekeeping = false,
    this.mealPrep = false,
    this.shopping = false,
    this.transportation = false,
    this.managingMedicines = false,
    this.laundry = false,
  });

  factory IADLModel.fromJson(Map<String, dynamic> json) {
    return IADLModel(
      id: json['id'],
      timeEntryId: json['time_entry_id'] ?? 0,
      date: json['date'] ?? '',
      housekeeping: json['housekeeping'] == 1 || json['housekeeping'] == true,
      mealPrep: json['meal_prep'] == 1 || json['meal_prep'] == true,
      shopping: json['shopping'] == 1 || json['shopping'] == true,
      transportation: json['transportation'] == 1 || json['transportation'] == true,
      managingMedicines: json['managing_medicines'] == 1 || json['managing_medicines'] == true,
      laundry: json['laundry'] == 1 || json['laundry'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_entry_id': timeEntryId,
      'date': date,
      'housekeeping': housekeeping ? 1 : 0,
      'meal_prep': mealPrep ? 1 : 0,
      'shopping': shopping ? 1 : 0,
      'transportation': transportation ? 1 : 0,
      'managing_medicines': managingMedicines ? 1 : 0,
      'laundry': laundry ? 1 : 0,
    };
  }
}