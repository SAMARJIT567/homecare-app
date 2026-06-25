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

    print('🟡 WeeklyReport: Loading report for entry: ${timeProvider.currentEntryId}');

    if (timeProvider.currentEntryId != null && timeProvider.currentEntryId! > 0) {
      await reportProvider.getReport(timeProvider.currentEntryId!);
    } else {
      print('🔴 No valid time entry ID found');
    }
  }

  Future<void> _generateReport() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    print('🟡 WeeklyReport: Generating report...');
    print('📋 Current Entry ID: ${timeProvider.currentEntryId}');

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

      print('📊 Response Status: ${response.status}');
      print('📝 Response Message: ${response.message}');

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
      print('🔴 Error generating report: $e');
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

    print('🟡 WeeklyReport: Building...');
    print('📊 Report: ${reportProvider.report != null ? "Available" : "Not available"}');
    print('📋 Entry ID: ${timeProvider.currentEntryId}');

    if (reportProvider.isLoading) {
      return const LoadingWidget();
    }

    if (reportProvider.report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No report available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete a shift and generate a report.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: timeProvider.hasActiveEntry ? null : _generateReport,
              text: 'Generate Report',
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    final report = reportProvider.report!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policyholder Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Policyholder Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Name', report.policyholder?['name'] as String? ?? ''),
                    _buildInfoRow('Policy #', report.policyholder?['policy_number'] as String? ?? ''),
                    _buildInfoRow('Phone', report.policyholder?['phone'] as String? ?? ''),
                    _buildInfoRow('Address', report.policyholder?['address'] as String? ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Service Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Date', report.dateOfService ?? ''),
                    _buildInfoRow('Time In', report.timeIn ?? ''),
                    _buildInfoRow('Time Out', report.timeOut ?? ''),
                    _buildInfoRow('Total Hours', report.totalHours?.toStringAsFixed(2) ?? ''),
                    _buildInfoRow('Rate', '\$${report.rate?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildInfoRow('Total Charge', '\$${report.totalCharge?.toStringAsFixed(2) ?? '0.00'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ADLs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activities of Daily Living (ADLs)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (report.adls != null)
                      ...report.adls!.entries.map((entry) {
                        final label = entry.key.split('_').map((e) =>
                        e[0].toUpperCase() + e.substring(1)
                        ).join(' ');
                        final value = entry.value as String? ?? 'Not provided';
                        return _buildInfoRow(label, value);
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // IADLs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instrumental ADLs (IADLs)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (report.iadls != null)
                      ...report.iadls!.entries.map((entry) {
                        final label = entry.key.split('_').map((e) =>
                        e[0].toUpperCase() + e.substring(1)
                        ).join(' ');
                        // ✅ Fixed: Handle both int and bool values
                        final value = entry.value;
                        final isChecked = value is bool
                            ? value
                            : (value is int ? value == 1 : false);
                        return _buildInfoRow(label, isChecked ? '✓' : '✗');
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Certification
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.certification ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}