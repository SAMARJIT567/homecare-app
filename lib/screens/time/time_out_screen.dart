import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/custom_text_field.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/core/utils/date_formatter.dart';
import 'package:homecare_app/screens/home/home_screen.dart';

class TimeOutScreen extends StatefulWidget {
  const TimeOutScreen({super.key});

  @override
  State<TimeOutScreen> createState() => _TimeOutScreenState();
}

class _TimeOutScreenState extends State<TimeOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateController = TextEditingController();
  String _selectedTime = DateFormatter.getCurrentTime();
  bool _isLoading = false;

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _timeOut() async {
    // ✅ Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final timeProvider = Provider.of<TimeProvider>(context, listen: false);

      // ✅ Parse rate
      final rate = double.tryParse(_rateController.text.trim());
      if (rate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid rate'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🟡 TimeOut: Time: $_selectedTime, Rate: $rate');

      final response = await timeProvider.registerTimeOut(
        _selectedTime,
        rate,
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
        // ✅ Show success with details
        final totalHours = timeProvider.totalHours?.toStringAsFixed(2) ?? '0.00';
        final totalCharge = timeProvider.totalCharge?.toStringAsFixed(2) ?? '0.00';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Shift completed! Total: $totalHours hrs, Charge: \$$totalCharge'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // ✅ Navigate back to Home after delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    } catch (e) {
      print('🔴 TimeOut Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⏹ Time Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'End your shift and calculate total hours',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Time In Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '⏰ Time In:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      timeProvider.timeInValue ?? 'Not started',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Time Out Picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time Out',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(_selectedTime),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Rate Input
              CustomTextField(
                controller: _rateController,
                label: 'Rate (\$)',
                hint: 'Enter hourly rate (e.g., 25.50)',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null) {
                    return 'Please enter a valid number';
                  }
                  if (rate <= 0) {
                    return 'Rate must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ✅ Button with loading state
              (_isLoading || timeProvider.isLoading)
                  ? const LoadingWidget()
                  : CustomButton(
                onPressed: _timeOut,
                text: '⏹ End Shift',
                isFullWidth: true,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}