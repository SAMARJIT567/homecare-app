import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/progress_provider.dart';
import 'package:homecare_app/core/constants/app_strings.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/widgets/adl_checkbox.dart';

class IADLScreen extends StatefulWidget {
  const IADLScreen({super.key});

  @override
  State<IADLScreen> createState() => _IADLScreenState();
}

class _IADLScreenState extends State<IADLScreen> {
  final Map<String, bool> _iadls = {
    'housekeeping': false,
    'meal_prep': false,
    'shopping': false,
    'transportation': false,
    'managing_medicines': false,
    'laundry': false,
  };

  bool _isLoading = false;

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

  Future<void> _saveIADLs() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (timeProvider.currentEntryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.timeInError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await progressProvider.saveProgress(
      timeEntryId: timeProvider.currentEntryId!,
      date: DateTime.now().toString().split(' ')[0],
      iadls: _iadls,
    );

    setState(() {
      _isLoading = false;
    });

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
          content: Text(AppStrings.iadlSaveSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetAll() {
    setState(() {
      _iadls.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);

    if (progressProvider.isLoading || _isLoading) {
      return const LoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.iadlTitle),
        actions: [
          TextButton(
            onPressed: _resetAll,
            child: const Text(
              AppStrings.resetAll,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.iadlHeader,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.iadlInstruction,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.assistanceProvidedIndicator,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // IADL Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ADLCheckbox(
                      label: AppStrings.housekeeping,
                      value: _iadls['housekeeping'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['housekeeping'] = value ?? false;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ADLCheckbox(
                      label: AppStrings.mealPreparation,
                      value: _iadls['meal_prep'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['meal_prep'] = value ?? false;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ADLCheckbox(
                      label: AppStrings.shopping,
                      value: _iadls['shopping'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['shopping'] = value ?? false;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ADLCheckbox(
                      label: AppStrings.transportation,
                      value: _iadls['transportation'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['transportation'] = value ?? false;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ADLCheckbox(
                      label: AppStrings.managingMedicines,
                      value: _iadls['managing_medicines'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['managing_medicines'] = value ?? false;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ADLCheckbox(
                      label: AppStrings.laundry,
                      value: _iadls['laundry'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _iadls['laundry'] = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.summaryHeader,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStrings.totalActivities),
                      Text('${_iadls.length}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStrings.assistanceProvided),
                      Text(
                        '${_iadls.values.where((v) => v == true).length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(AppStrings.noAssistanceNeeded),
                      Text(
                        '${_iadls.values.where((v) => v == false).length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _iadls.values.where((v) => v == true).length /
                        _iadls.length,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              onPressed: _saveIADLs,
              text: AppStrings.saveIADLs,
              isFullWidth: true,
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                // Navigate to ADLs screen
                Navigator.pushNamed(context, '/daily-progress');
              },
              child: const Text(AppStrings.backToADLs),
            ),
          ],
        ),
      ),
    );
  }
}