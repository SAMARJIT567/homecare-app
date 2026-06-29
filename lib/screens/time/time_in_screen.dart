import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/core/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/auth_provider.dart';
import 'package:homecare_app/widgets/custom_button.dart';
import 'package:homecare_app/widgets/custom_text_field.dart';
import 'package:homecare_app/widgets/loading_widget.dart';
import 'package:homecare_app/core/utils/date_formatter.dart';
import 'package:homecare_app/screens/home/home_screen.dart';
import 'package:homecare_app/core/network/api_service.dart';
import 'package:homecare_app/core/constants/app_constants.dart';

class TimeInScreen extends StatefulWidget {
  const TimeInScreen({super.key});

  @override
  State<TimeInScreen> createState() => _TimeInScreenState();
}

class _TimeInScreenState extends State<TimeInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _policyholderNameController = TextEditingController();
  final _policyholderIdController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _providerPhoneController = TextEditingController();

  String _selectedDate = DateFormatter.getCurrentDate();
  String _selectedTimeIn = DateFormatter.getCurrentTime();

  bool _isLoading = false;
  bool _isLoadingPolicyholders = false;

  // ✅ Policyholder Dropdown
  List<Map<String, dynamic>> _policyholders = [];
  Map<String, dynamic>? _selectedPolicyholder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderData();
      _loadPolicyholders();
    });
  }

  // ✅ Load provider (caregiver) data
  void _loadProviderData() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final user = authProvider.user!;
        _providerNameController.text = user.name;

        // ✅ Use formattedPhone helper
        _providerPhoneController.text = user.hasPhone ? user.phone! : 'Not available';

        print('✅ Provider loaded: ${user.name}');
        print('📱 Phone: ${user.hasPhone ? user.phone : 'Not available'}');
      } else {
        _providerNameController.text = 'Loading...';
        _providerPhoneController.text = 'Loading...';
      }
    } catch (e) {
      print('🔴 Error loading auth provider: $e');
      _providerNameController.text = 'Error loading';
      _providerPhoneController.text = 'Error loading';
    }
  }

  // ✅ Load policyholders from database (Caregiver endpoint)
  Future<void> _loadPolicyholders() async {
    setState(() {
      _isLoadingPolicyholders = true;
    });

    try {
      final apiService = ApiService();
      final token = await _getToken();

      if (token == null) {
        print('🔴 No token found');
        setState(() {
          _isLoadingPolicyholders = false;
        });
        return;
      }

      print('🟡 Fetching policyholders...');

      // ✅ Use caregiver endpoint
      final response = await apiService.dio.get(
        ApiEndpoints.policyholdersList,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      print('📊 Response: $data');

      if (data != null && data['status'] == true) {
        final List<dynamic> policyholdersData = data['data'] ?? [];
        setState(() {
          _policyholders = policyholdersData
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
        print('✅ Loaded ${_policyholders.length} policyholders');

        // ✅ Log completed shifts for debugging
        for (var p in _policyholders) {
          final completed = p['completed_shifts'] ?? 0;
          if (completed > 0) {
            print('⚠️ ${p['name']} has $completed completed shift(s)');
          }
        }
      } else {
        print('🔴 Failed to load policyholders: ${data?['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load policyholders: ${data?['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('🔴 Error loading policyholders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading policyholders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPolicyholders = false;
        });
      }
    }
  }

  // ✅ Get token from shared preferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.tokenKey);
    } catch (e) {
      print('🔴 Error getting token: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _policyholderNameController.dispose();
    _policyholderIdController.dispose();
    _providerNameController.dispose();
    _providerPhoneController.dispose();
    super.dispose();
  }

  // ✅ Select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            DateFormatter.formatDateTime(picked, format: 'yyyy-MM-dd');
      });
    }
  }

  // ✅ Select time
  Future<void> _selectTimeIn(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTimeIn =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ✅ Start shift
  Future<void> _startShift() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPolicyholder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a policyholder'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Check if policyholder has completed shifts
    final completedShifts = _selectedPolicyholder!['completed_shifts'] ?? 0;
    if (completedShifts > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ ${_selectedPolicyholder!['name']} already has $completedShifts completed shift(s). '
                'You cannot start a new shift for this policyholder.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final timeProvider = Provider.of<TimeProvider>(context, listen: false);

      final policyholderId = _selectedPolicyholder!['id'] as int;

      print('🟡 Starting shift for policyholder ID: $policyholderId');
      print('📅 Date: $_selectedDate');
      print('⏰ Time: $_selectedTimeIn');

      final response = await timeProvider.registerTimeIn(
        policyholderId,
        _selectedDate,
        _selectedTimeIn,
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
            content: Text('✅ Shift started successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('🔴 Error starting shift: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Start Shift',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Begin Shift',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Start your caregiving session',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_ind_outlined,
                              size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Policyholder & Provider',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ✅ Policyholder Name - Dropdown with disabled items
                      _buildPolicyholderDropdown(),

                      const SizedBox(height: 16),

                      // ✅ Policyholder ID - Auto-filled
                      CustomTextField(
                        controller: _policyholderIdController,
                        label: 'Policyholder ID',
                        hint: 'Auto-filled from selection',
                        prefixIcon: Icons.badge_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Provider Name - Auto-filled
                      CustomTextField(
                        controller: _providerNameController,
                        label: 'Provider (Caregiver)',
                        hint: 'Auto-filled',
                        prefixIcon: Icons.medical_services_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Provider Phone - Auto-filled
                      CustomTextField(
                        controller: _providerPhoneController,
                        label: 'Provider Phone',
                        hint: 'Auto-filled',
                        prefixIcon: Icons.phone_android_outlined,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Schedule Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event_available_outlined,
                            size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Shift Schedule',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_rounded,
                              color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _selectedDate,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectTimeIn(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time In',
                          labelStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                          ),
                          prefixIcon: const Icon(
                              Icons.access_time_filled_rounded,
                              color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          _selectedTimeIn,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button
              (_isLoading || timeProvider.isLoading)
                  ? const Center(child: LoadingWidget())
                  : CustomButton(
                onPressed: _startShift,
                text: '▶ Start Shift',
                isFullWidth: true,
              ),

              const SizedBox(height: 16),
              _buildLegalDisclaimer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Policyholder Dropdown Widget with Disabled Items
  Widget _buildPolicyholderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Policyholder Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _isLoadingPolicyholders
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading policyholders...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
              : DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedPolicyholder,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              hintText: _policyholders.isEmpty
                  ? 'No policyholders found'
                  : 'Select a policyholder',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
            items: _policyholders.map((policyholder) {
              final completedShifts = policyholder['completed_shifts'] ?? 0;
              final isDisabled = completedShifts > 0;
              final name = policyholder['name'] ?? 'Unknown';

              return DropdownMenuItem<Map<String, dynamic>>(
                value: isDisabled ? null : policyholder,
                enabled: !isDisabled,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isDisabled ? FontWeight.normal : FontWeight.w500,
                          color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                          decoration: isDisabled ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDisabled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: _policyholders.isEmpty
                ? null
                : (Map<String, dynamic>? value) {
              if (value == null) {
                // ✅ Show message when trying to select disabled item
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '⚠️ This policyholder already has a completed shift. '
                          'You cannot start a new shift for this policyholder.',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              setState(() {
                _selectedPolicyholder = value;
                _policyholderNameController.text = value['name'] ?? '';
                _policyholderIdController.text = value['id']?.toString() ?? '';
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a policyholder';
              }
              return null;
            },
          ),
        ),
        if (_policyholders.isEmpty && !_isLoadingPolicyholders)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '⚠️ No policyholders available. Please add one from admin panel.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        // ✅ Info message about disabled policyholders
        if (_policyholders.any((p) => (p['completed_shifts'] ?? 0) > 0))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '⚠️ Policyholders with "Done" badge already have completed shifts.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        '⚠️ By signing, I certify that the information is true and accurate. False claims are punishable.',
        style: TextStyle(
          fontSize: 8,
          color: Colors.grey,
          height: 1.1,
        ),
      ),
    );
  }
}