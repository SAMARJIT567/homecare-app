class AdminUser {
  final int id;
  final String name;
  final String email;
  final String role;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return AdminUser(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
    );
  }
}

class DashboardStats {
  final int totalCaregivers;
  final int totalPolicyholders;
  final int totalShifts;
  final double totalRevenue;
  final int pendingShifts;
  final List<dynamic> recentShifts;
  final List<dynamic> weeklyData;

  DashboardStats({
    required this.totalCaregivers,
    required this.totalPolicyholders,
    required this.totalShifts,
    required this.totalRevenue,
    required this.pendingShifts,
    required this.recentShifts,
    required this.weeklyData,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DashboardStats(
      totalCaregivers: _parseInt(stats['total_caregivers']),
      totalPolicyholders: _parseInt(stats['total_policyholders']),
      totalShifts: _parseInt(stats['total_shifts']),
      totalRevenue: _parseDouble(stats['total_revenue']),
      pendingShifts: _parseInt(stats['pending_shifts']),
      recentShifts: json['recent_shifts'] ?? [],
      weeklyData: json['weekly_data'] ?? [],
    );
  }
}

class Caregiver {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final int totalShifts;
  final double totalRevenue;

  Caregiver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.totalShifts = 0,
    this.totalRevenue = 0,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Caregiver(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      totalShifts: _parseInt(json['total_shifts']),
      totalRevenue: _parseDouble(json['total_revenue']),
    );
  }
}

class Policyholder {
  final int id;
  final String name;
  final String policyNumber;
  final String phone;
  final String? address;
  final int totalShifts;

  Policyholder({
    required this.id,
    required this.name,
    required this.policyNumber,
    required this.phone,
    this.address,
    this.totalShifts = 0,
  });

  factory Policyholder.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Policyholder(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      policyNumber: json['policy_number'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      totalShifts: _parseInt(json['total_shifts']),
    );
  }
}

class Shift {
  final int id;
  final int caregiverId;
  final int policyholderId;
  final String date;
  final String timeIn;
  final String? timeOut;
  final double totalHours;
  final double rate;
  final double totalCharge;
  final String status;
  final String caregiverName;
  final String policyholderName;
  final String? adminStatus;

  Shift({
    required this.id,
    required this.caregiverId,
    required this.policyholderId,
    required this.date,
    required this.timeIn,
    this.timeOut,
    required this.totalHours,
    required this.rate,
    required this.totalCharge,
    required this.status,
    required this.caregiverName,
    required this.policyholderName,
    this.adminStatus,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Shift(
      id: _parseInt(json['id']),
      caregiverId: _parseInt(json['caregiver_id']),
      policyholderId: _parseInt(json['policyholder_id']),
      date: json['date'] ?? '',
      timeIn: json['time_in'] ?? '',
      timeOut: json['time_out'],
      totalHours: _parseDouble(json['total_hours']),
      rate: _parseDouble(json['rate']),
      totalCharge: _parseDouble(json['total_charge']),
      status: json['status'] ?? '',
      caregiverName: json['caregiver_name'] ?? '',
      policyholderName: json['policyholder_name'] ?? '',
      adminStatus: json['admin_status'],
    );
  }
}
