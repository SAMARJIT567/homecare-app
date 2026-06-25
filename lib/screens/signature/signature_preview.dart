import 'dart:convert';
import 'package:flutter/material.dart';

class SignaturePreviewScreen extends StatelessWidget {
  final String? caregiverSignature;
  final String? policyholderSignature;

  const SignaturePreviewScreen({
    super.key,
    this.caregiverSignature,
    this.policyholderSignature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Preview'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caregiver Signature
            const Text(
              '👤 Caregiver Signature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: _buildSignatureImage(caregiverSignature),
            ),
            const SizedBox(height: 8),
            Text(
              caregiverSignature != null ? '✅ Signature captured' : '❌ No signature provided',
              style: TextStyle(
                fontSize: 12,
                color: caregiverSignature != null ? Colors.green : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Policyholder Signature
            const Text(
              '👤 Policyholder Signature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: _buildSignatureImage(policyholderSignature),
            ),
            const SizedBox(height: 8),
            Text(
              policyholderSignature != null ? '✅ Signature captured' : '❌ No signature provided',
              style: TextStyle(
                fontSize: 12,
                color: policyholderSignature != null ? Colors.green : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureImage(String? signature) {
    if (signature == null || signature.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_off,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'No signature provided',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    try {
      final base64String = _extractBase64(signature);
      final bytes = base64Decode(base64String);

      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to load signature',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('🔴 Signature Preview Error: $e');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.orange,
            ),
            SizedBox(height: 8),
            Text(
              'Invalid signature format',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _extractBase64(String signature) {
    // If signature has data:image/png;base64, prefix, extract the base64 part
    if (signature.contains(',')) {
      return signature.split(',').last;
    }
    return signature;
  }
}