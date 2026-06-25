import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/progress_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/core/constants/app_constants.dart';
import 'package:homecare_app/screens/home/home_screen.dart';

class DailyProgressScreen extends StatefulWidget {
  const DailyProgressScreen({super.key});

  @override
  State<DailyProgressScreen> createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  final Map<String, String?> _adls = {
    'bathing': null,
    'mobility': null,
    'bed_chair': null,
    'continence': null,
    'eating': null,
    'toileting': null,
    'dressing': null,
    'medication': null,
  };

  final Map<String, bool> _iadls = {
    'housekeeping': false,
    'meal_prep': false,
    'shopping': false,
    'transportation': false,
    'managing_medicines': false,
    'laundry': false,
  };

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (timeProvider.currentEntryId != null) {
      await progressProvider.getProgress(timeProvider.currentEntryId!);

      if (progressProvider.dailyProgress != null) {
        final data = progressProvider.dailyProgress!;
        setState(() {
          _adls['bathing'] = data.bathing;
          _adls['mobility'] = data.mobility;
          _adls['bed_chair'] = data.bedChair;
          _adls['continence'] = data.continence;
          _adls['eating'] = data.eating;
          _adls['toileting'] = data.toileting;
          _adls['dressing'] = data.dressing;
          _adls['medication'] = data.medication;
        });
      }

      if (progressProvider.iadls != null) {
        final data = progressProvider.iadls!;
        setState(() {
          _iadls['housekeeping'] = data.housekeeping;
          _iadls['meal_prep'] = data.mealPrep;
          _iadls['shopping'] = data.shopping;
          _iadls['transportation'] = data.transportation;
          _iadls['managing_medicines'] = data.managingMedicines;
          _iadls['laundry'] = data.laundry;
        });
      }
    }
  }

  Future<void> _saveProgress() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (timeProvider.currentEntryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please time-in first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Check if all ADLs are filled
    final hasEmptyADL = _adls.values.any((value) => value == null);
    if (hasEmptyADL) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all ADL levels!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await progressProvider.saveProgress(
      timeEntryId: timeProvider.currentEntryId!,
      date: DateTime.now().toString().split(' ')[0],
      adls: _adls,
      iadls: _iadls,
    );

    if (!mounted) return;

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
          content: Text('✅ Progress saved! You can now end your shift.'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Navigate back to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showADLSelector(String key, String label) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select $label Level',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the level of assistance required:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ...AppConstants.adlLevels.map((level) {
              return ListTile(
                title: Text(
                  AppConstants.adlLevelMap[level] ?? level,
                  style: const TextStyle(fontSize: 16),
                ),
                leading: Radio<String>(
                  value: level,
                  groupValue: _adls[key],
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _adls[key] = value;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  setState(() {
                    _adls[key] = level;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final hasEmptyADL = _adls.values.any((value) => value == null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProgress,
          ),
        ],
      ),
      body: progressProvider.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasEmptyADL ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasEmptyADL ? Colors.orange.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasEmptyADL ? Icons.warning : Icons.check_circle,
                    color: hasEmptyADL ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasEmptyADL
                          ? 'Please fill all ADL levels before saving'
                          : 'All ADLs filled! Ready to save.',
                      style: TextStyle(
                        color: hasEmptyADL ? Colors.orange.shade800 : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ADLs Section
            const Text(
              '📋 Activities of Daily Living (ADLs)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap on each activity to select the level of assistance:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._adls.keys.map((key) {
              final label = key.split('_').map((e) =>
              e[0].toUpperCase() + e.substring(1)
              ).join(' ');
              final isSelected = _adls[key] != null;
              return Card(
                elevation: isSelected ? 2 : 0,
                child: ListTile(
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_adls[key] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _adls[key]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  onTap: () => _showADLSelector(key, label),
                ),
              );
            }),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // IADLs Section
            const Text(
              '🛠 Instrumental ADLs (IADLs)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check if assistance was provided for each activity:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._iadls.keys.map((key) {
              final label = key.split('_').map((e) =>
              e[0].toUpperCase() + e.substring(1)
              ).join(' ');
              return Card(
                child: CheckboxListTile(
                  title: Text(label),
                  value: _iadls[key],
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _iadls[key] = value ?? false;
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 24),
            CustomButton(
              onPressed: _saveProgress,
              text: '💾 Save Progress',
              isFullWidth: true,
              color: hasEmptyADL ? Colors.orange : Colors.blue,
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text('← Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}