import 'package:flutter/material.dart';

class ReportPreviewScreen extends StatelessWidget {
  final Map<String, dynamic>? reportData;

  const ReportPreviewScreen({super.key, this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // PDF generation logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF generation coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: reportData == null
          ? const Center(
        child: Text('No report data available'),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Text(
                    'Weekly Care Certification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Week: ${reportData?['week_start'] ?? ''} to ${reportData?['week_end'] ?? ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Policyholder Info
            _buildSection(
              'Policyholder Information',
              [
                _buildRow('Name', reportData?['policyholder']?['name'] ?? ''),
                _buildRow('Policy Number', reportData?['policyholder']?['policy_number'] ?? ''),
                _buildRow('Phone', reportData?['policyholder']?['phone'] ?? ''),
                _buildRow('Address', reportData?['policyholder']?['address'] ?? ''),
              ],
            ),
            const SizedBox(height: 16),

            // Service Details
            _buildSection(
              'Service Details',
              [
                _buildRow('Date', reportData?['time_entry']?['date'] ?? ''),
                _buildRow('Time In', reportData?['time_entry']?['time_in'] ?? ''),
                _buildRow('Time Out', reportData?['time_entry']?['time_out'] ?? ''),
                _buildRow('Total Hours', reportData?['time_entry']?['total_hours']?.toStringAsFixed(2) ?? ''),
                _buildRow('Rate', '\$${reportData?['time_entry']?['rate']?.toStringAsFixed(2) ?? '0.00'}'),
                _buildRow('Total Charge', '\$${reportData?['time_entry']?['total_charge']?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
            const SizedBox(height: 16),

            // ADLs
            _buildSection(
              'Activities of Daily Living (ADLs)',
              [
                _buildRow('Bathing', reportData?['adls']?['bathing'] ?? ''),
                _buildRow('Mobility', reportData?['adls']?['mobility'] ?? ''),
                _buildRow('Bed/Chair', reportData?['adls']?['bed_chair'] ?? ''),
                _buildRow('Continence', reportData?['adls']?['continence'] ?? ''),
                _buildRow('Eating', reportData?['adls']?['eating'] ?? ''),
                _buildRow('Toileting', reportData?['adls']?['toileting'] ?? ''),
                _buildRow('Dressing', reportData?['adls']?['dressing'] ?? ''),
                _buildRow('Medication', reportData?['adls']?['medication'] ?? ''),
              ],
            ),
            const SizedBox(height: 16),

            // IADLs
            _buildSection(
              'Instrumental ADLs (IADLs)',
              [
                _buildRow('Housekeeping', _getIADLValue(reportData?['iadls']?['housekeeping'])),
                _buildRow('Meal Preparation', _getIADLValue(reportData?['iadls']?['meal_prep'])),
                _buildRow('Shopping', _getIADLValue(reportData?['iadls']?['shopping'])),
                _buildRow('Transportation', _getIADLValue(reportData?['iadls']?['transportation'])),
                _buildRow('Managing Medicines', _getIADLValue(reportData?['iadls']?['managing_medicines'])),
                _buildRow('Laundry', _getIADLValue(reportData?['iadls']?['laundry'])),
              ],
            ),
            const SizedBox(height: 24),

            // Signatures
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Signatures',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRow('Caregiver', reportData?['signatures']?['caregiver'] != null ? '✓ Signed' : 'Not Signed'),
                    _buildRow('Policyholder', reportData?['signatures']?['policyholder'] != null ? '✓ Signed' : 'Not Signed'),
                    _buildRow('Caregiver Date', reportData?['signatures']?['caregiver_date'] ?? ''),
                    _buildRow('Policyholder Date', reportData?['signatures']?['policyholder_date'] ?? ''),
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
                      reportData?['certification'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  String _getIADLValue(dynamic value) {
    if (value == true || value == 1) {
      return '✓ Provided';
    }
    return '✗ Not Provided';
  }
}