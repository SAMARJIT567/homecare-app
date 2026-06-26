import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/report_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/loading_widget.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (timeProvider.currentEntryId != null && timeProvider.currentEntryId! > 0) {
      await reportProvider.getReport(timeProvider.currentEntryId!);
    }
  }

  Future<void> _generateReport() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (timeProvider.currentEntryId == null || timeProvider.currentEntryId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid time entry found!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await reportProvider.generateReport(
        timeProvider.currentEntryId!,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (!response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadReport();
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);

    if (reportProvider.isLoading) {
      return const LoadingWidget();
    }

    if (reportProvider.report == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Report Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please complete a shift and generate a report.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: timeProvider.hasActiveEntry ? null : _generateReport,
                text: '📄 Generate Report',
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    final report = reportProvider.report!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Weekly Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _generateReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Care Certification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Report for week ending ${report.dateOfService ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Policyholder Info
              _buildSectionCard(
                icon: Icons.person,
                title: 'Policyholder Information',
                color: Colors.blue,
                children: [
                  _buildInfoRow('Name', report.policyholder?['name'] as String? ?? ''),
                  _buildInfoRow('Policy #', report.policyholder?['policy_number'] as String? ?? ''),
                  _buildInfoRow('Phone', report.policyholder?['phone'] as String? ?? ''),
                  _buildInfoRow('Address', report.policyholder?['address'] as String? ?? ''),
                ],
              ),
              const SizedBox(height: 14),

              // Service Details
              _buildSectionCard(
                icon: Icons.access_time,
                title: 'Service Details',
                color: Colors.orange,
                children: [
                  _buildInfoRow('Date', report.dateOfService ?? ''),
                  _buildInfoRow('Time In', report.timeIn ?? ''),
                  _buildInfoRow('Time Out', report.timeOut ?? ''),
                  _buildInfoRow('Total Hours', report.totalHours?.toStringAsFixed(2) ?? ''),
                  _buildInfoRow('Rate', '\$${report.rate?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildInfoRow('Total Charge', '\$${report.totalCharge?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
              const SizedBox(height: 14),

              // ADLs
              _buildSectionCard(
                icon: Icons.medical_services,
                title: 'Activities of Daily Living (ADLs)',
                color: Colors.blue,
                children: report.adls != null
                    ? report.adls!.entries.map((entry) {
                  final label = entry.key.split('_').map((e) =>
                  e[0].toUpperCase() + e.substring(1)
                  ).join(' ');
                  final value = entry.value as String? ?? 'Not provided';
                  final levelMap = {
                    'I': 'Independent',
                    'S': 'Supervision',
                    'A': 'Stand-by Assistance',
                    'H': 'Hands On Assistance'
                  };
                  final displayValue = levelMap[value] ?? value;
                  return _buildInfoRow(label, displayValue, isBold: value != null);
                }).toList()
                    : [],
              ),
              const SizedBox(height: 14),

              // IADLs
              _buildSectionCard(
                icon: Icons.house,
                title: 'Instrumental ADLs (IADLs)',
                color: Colors.green,
                children: report.iadls != null
                    ? report.iadls!.entries.map((entry) {
                  final label = entry.key.split('_').map((e) =>
                  e[0].toUpperCase() + e.substring(1)
                  ).join(' ');
                  final value = entry.value as bool? ?? false;
                  return _buildInfoRow(label, value ? '✅ Provided' : '❌ Not Provided');
                }).toList()
                    : [],
              ),
              const SizedBox(height: 14),

              // Signatures
              _buildSectionCard(
                icon: Icons.edit,
                title: 'Signatures',
                color: Colors.purple,
                children: [
                  _buildInfoRow(
                    'Caregiver',
                    report.signatures?['caregiver'] != null ? '✅ Signed' : '❌ Not Signed',
                  ),
                  _buildInfoRow(
                    'Policyholder',
                    report.signatures?['policyholder'] != null ? '✅ Signed' : '❌ Not Signed',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Certification
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.gavel,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Certification',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.certification ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: isBold ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}