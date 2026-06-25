import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/signature_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/screens/report/weekly_report_screen.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late SignatureController _caregiverController;
  late SignatureController _policyholderController;

  bool _caregiverSigned = false;
  bool _policyholderSigned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _caregiverController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.blue,
      exportBackgroundColor: Colors.white,
    );
    _policyholderController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.blue,
      exportBackgroundColor: Colors.white,
    );

    _caregiverController.addListener(() {
      if (mounted) {
        setState(() {
          _caregiverSigned = _caregiverController.isNotEmpty;
        });
      }
    });

    _policyholderController.addListener(() {
      if (mounted) {
        setState(() {
          _policyholderSigned = _policyholderController.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _caregiverController.dispose();
    _policyholderController.dispose();
    super.dispose();
  }

  Future<void> _saveSignatures() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final signatureProvider = Provider.of<SignatureProvider>(context, listen: false);

    // Check if time entry exists
    if (timeProvider.currentEntryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please time-in first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if both signatures are provided
    if (!_caregiverSigned || !_policyholderSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both signatures!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Export signatures as PNG bytes
      final caregiverSignature = await _caregiverController.toPngBytes();
      final policyholderSignature = await _policyholderController.toPngBytes();

      if (caregiverSignature == null || policyholderSignature == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture signatures. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert to base64 with data URI
      final caregiverBase64 = 'data:image/png;base64,${base64Encode(caregiverSignature)}';
      final policyholderBase64 = 'data:image/png;base64,${base64Encode(policyholderSignature)}';

      // Save signatures
      final response = await signatureProvider.saveSignature(
        timeEntryId: timeProvider.currentEntryId!,
        caregiverSignature: caregiverBase64,
        policyholderSignature: policyholderBase64,
      );

      if (!mounted) return;

      if (!response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signatures saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate directly to Report Screen after save
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const WeeklyReportScreen(),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('🔴 Signature Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSignatures() {
    _caregiverController.clear();
    _policyholderController.clear();
    setState(() {
      _caregiverSigned = false;
      _policyholderSigned = false;
    });
  }

  // ✅ Separate method for onPressed - returns void, not Future
  void _onSavePressed() {
    _saveSignatures();
  }

  @override
  Widget build(BuildContext context) {
    final signatureProvider = Provider.of<SignatureProvider>(context);

    // Check if both signatures are signed
    final bool canSave = _caregiverSigned && _policyholderSigned;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signatures'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          TextButton(
            onPressed: _clearSignatures,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: (_isLoading || signatureProvider.isLoading)
          ? const LoadingWidget()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Caregiver Signature
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '👤 Caregiver Signature',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            _caregiverSigned ? 'Signed ✅' : 'Pending ⚠️',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _caregiverSigned ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _caregiverSigned ? Colors.green : Colors.grey.shade400,
                          width: _caregiverSigned ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Signature(
                        controller: _caregiverController,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _caregiverSigned
                              ? '✅ Signature captured'
                              : '✍️ Sign above using finger/stylus',
                          style: TextStyle(
                            fontSize: 12,
                            color: _caregiverSigned ? Colors.green : Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _caregiverController.clear();
                            setState(() {
                              _caregiverSigned = false;
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Policyholder Signature
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '👤 Policyholder Signature',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            _policyholderSigned ? 'Signed ✅' : 'Pending ⚠️',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _policyholderSigned ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _policyholderSigned ? Colors.green : Colors.grey.shade400,
                          width: _policyholderSigned ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Signature(
                        controller: _policyholderController,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _policyholderSigned
                              ? '✅ Signature captured'
                              : '✍️ Sign above using finger/stylus',
                          style: TextStyle(
                            fontSize: 12,
                            color: _policyholderSigned ? Colors.green : Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _policyholderController.clear();
                            setState(() {
                              _policyholderSigned = false;
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Fixed: Save Button - Uses _onSavePressed (void)
            CustomButton(
              onPressed: canSave ? _onSavePressed : null,
              text: '💾 Save Signatures',
              isFullWidth: true,
              color: canSave ? Colors.green : Colors.grey,
            ),

            const SizedBox(height: 16),
            Text(
              'Please sign using your finger or stylus on the above pads.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),
            // Back to Home button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('← Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}