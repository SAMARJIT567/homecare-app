import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pdf_generator/simple_pdf_generator.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/report_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/core/utils/globals.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  Future<void> _loadReport() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (timeProvider.currentEntryId != null &&
        timeProvider.currentEntryId! > 0) {
      await reportProvider.getReport(timeProvider.currentEntryId!);
    }
  }

  Future<void> _downloadReport() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (timeProvider.currentEntryId == null ||
        timeProvider.currentEntryId! <= 0) {
      Globals.scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('No valid time entry found!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Ask for permission (Dialog)
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.folder_shared, color: Colors.blue),
            SizedBox(width: 10),
            Text('Save to Device'),
          ],
        ),
        content: const Text(
          'Do you want to grant permission to save this report PDF to your device\'s local storage?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Grant & Save'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 3. Ensure report is generated on server
      if (reportProvider.report == null) {
        final response = await reportProvider.generateReport(
          timeProvider.currentEntryId!,
        );
        if (!response.status) {
          if (!mounted) return;
          Navigator.pop(context);
          Globals.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Generation failed: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final report = reportProvider.report!;

      // 4. Actual PDF Generation logic using simple_pdf_generator
      final List<Map<String, dynamic>> tableData = [
        {
          'Field': 'Policyholder',
          'Detail': report.policyholder?['name']?.toString() ?? 'N/A'
        },
        {
          'Field': 'Policy #',
          'Detail': report.policyholder?['policy_number']?.toString() ?? 'N/A'
        },
        {'Field': 'Date', 'Detail': report.dateOfService ?? 'N/A'},
        {'Field': 'Time In', 'Detail': report.timeIn ?? 'N/A'},
        {'Field': 'Time Out', 'Detail': report.timeOut ?? 'N/A'},
        {
          'Field': 'Total Hours',
          'Detail': report.totalHours?.toStringAsFixed(2) ?? '0.00'
        },
        {
          'Field': 'Total Charge',
          'Detail': '\$${report.totalCharge?.toStringAsFixed(2) ?? '0.00'}'
        },
      ];

      // Add ADLs/IADLs to data
      if (report.adls != null) {
        report.adls!.forEach((key, value) {
          if (key != 'id' &&
              key != 'time_entry_id' &&
              key != 'date' &&
              key != 'created_at') {
            final label = key
                .split('_')
                .map((e) => e[0].toUpperCase() + e.substring(1))
                .join(' ');
            tableData
                .add({'Field': label, 'Detail': value?.toString() ?? 'N/A'});
          }
        });
      }

      final pdfDoc = await SimplePdf.generate(
        header: PdfHeader(
          title: 'Care Certification Report',
          subtitle: 'Generated on ${DateTime.now().toString().split('.')[0]}',
        ),
        tables: [
          PdfTable(
            headers: ['Field', 'Detail'],
            data: tableData,
          ),
        ],
      );

      // 5. Save the PDF file
      final bytes = await pdfDoc.save();
      final fileName =
          'Homecare_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      Directory? directory;
      if (Platform.isAndroid) {
        // Use the external downloads directory which is visible in File Manager
        // path: /storage/emulated/0/Android/data/com.package.name/files/Download
        final List<Directory>? externalDirs =
            await getExternalStorageDirectories(
                type: StorageDirectory.downloads);
        directory = externalDirs?.isNotEmpty == true
            ? externalDirs!.first
            : await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null)
        throw Exception('Could not find a directory to save the file.');

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String path = '${directory.path}/$fileName';
      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      Globals.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅ Report saved to device!'),
              Text(
                'Path: $path',
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Globals.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReport,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadReport,
            tooltip: 'Download Report',
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const LoadingWidget()
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: reportProvider.report == null
                  ? _buildNoReportView(timeProvider)
                  : _buildReportContent(reportProvider.report!),
            ),
    );
  }

  Widget _buildNoReportView(TimeProvider timeProvider) {
    return Center(
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
              Icons.download_for_offline,
              size: 60,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Report Not Downloaded',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete a shift to download your report.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: timeProvider.hasActiveEntry ? null : _downloadReport,
            text: '📥 Download Report',
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(var report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
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
                    Icons.file_download,
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
                        'Care Certification Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Report for ending ${report.dateOfService ?? ''}',
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
              _buildInfoRow(
                  'Name', report.policyholder?['name']?.toString() ?? ''),
              _buildInfoRow('Policy #',
                  report.policyholder?['policy_number']?.toString() ?? ''),
              _buildInfoRow(
                  'Phone', report.policyholder?['phone']?.toString() ?? ''),
              _buildInfoRow(
                  'Address', report.policyholder?['address']?.toString() ?? ''),
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
              _buildInfoRow('Total Hours',
                  report.totalHours?.toStringAsFixed(2) ?? '0.00'),
              _buildInfoRow(
                  'Rate', '\$${report.rate?.toStringAsFixed(2) ?? '0.00'}'),
              _buildInfoRow('Total Charge',
                  '\$${report.totalCharge?.toStringAsFixed(2) ?? '0.00'}',
                  isBold: true),
            ],
          ),
          const SizedBox(height: 14),

          // ADLs
          _buildSectionCard(
            icon: Icons.medical_services,
            title: 'Activities of Daily Living (ADLs)',
            color: Colors.blue,
            children: report.adls != null
                ? report.adls!.entries
                    .where((e) =>
                        e.key != 'id' &&
                        e.key != 'time_entry_id' &&
                        e.key != 'date' &&
                        e.key != 'created_at')
                    .map<Widget>((entry) {
                    final label = entry.key
                        .split('_')
                        .map((e) => e[0].toUpperCase() + e.substring(1))
                        .join(' ');
                    final value = entry.value?.toString() ?? 'Not provided';
                    final levelMap = {
                      'I': 'Independent',
                      'S': 'Supervision',
                      'A': 'Stand-by Assistance',
                      'H': 'Hands On Assistance'
                    };
                    final displayValue = levelMap[value] ?? value;
                    return _buildInfoRow(label, displayValue, isBold: true);
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
                ? report.iadls!.entries
                    .where((e) =>
                        e.key != 'id' &&
                        e.key != 'time_entry_id' &&
                        e.key != 'date' &&
                        e.key != 'created_at')
                    .map<Widget>((entry) {
                    final label = entry.key
                        .split('_')
                        .map((e) => e[0].toUpperCase() + e.substring(1))
                        .join(' ');

                    final value = entry.value;
                    final bool isProvided =
                        (value == true || value == 1 || value == '1');

                    return _buildInfoRow(
                        label, isProvided ? '✅ Provided' : '❌ Not Provided');
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
              _buildSignatureRow(
                'Caregiver',
                report.signatures?['caregiver_signature']?.toString(),
              ),
              const Divider(height: 20),
              _buildSignatureRow(
                'Policyholder',
                report.signatures?['policyholder_signature']?.toString(),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSignatureRow(String label, String? base64Image) {
    final bool isSigned = base64Image != null && base64Image.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isSigned ? '✅ Signed' : '❌ Not Signed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSigned ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        if (isSigned) ...[
          const SizedBox(height: 8),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Image.memory(
              base64.decode(base64Image.split(',').last),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ],
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
