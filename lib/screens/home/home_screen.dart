import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/auth_provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/signature_provider.dart';
import 'package:homecare_app/providers/progress_provider.dart';
import 'package:homecare_app/screens/time/time_in_screen.dart';
import 'package:homecare_app/screens/time/time_out_screen.dart';
import 'package:homecare_app/screens/progress/daily_progress_screen.dart';
import 'package:homecare_app/screens/report/weekly_report_screen.dart';
import 'package:homecare_app/screens/signature/signature_screen.dart';
import 'package:homecare_app/widgets/home_action_card.dart';
import 'package:homecare_app/core/utils/date_formatter.dart';
import 'package:homecare_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  bool _signaturesExist = false;
  bool _progressCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    try {
      final timeProvider = Provider.of<TimeProvider>(context, listen: false);
      final signatureProvider =
      Provider.of<SignatureProvider>(context, listen: false);
      final progressProvider =
      Provider.of<ProgressProvider>(context, listen: false);

      final date = DateFormatter.getCurrentDate();
      await timeProvider.getTodayLog(date);
      print('✅ Today log loaded');

      if (timeProvider.currentEntryId != null) {
        final entryId = timeProvider.currentEntryId!;

        await Future.wait([
          signatureProvider.getSignature(entryId),
          progressProvider.getProgress(entryId),
        ]);
        print('✅ Status data loaded');
      }

      if (mounted) {
        setState(() {
          _signaturesExist = signatureProvider.signature != null;
          _progressCompleted = progressProvider.dailyProgress != null;
          _isLoading = false;
        });

        print('📊 Final Status:');
        print('  - Signatures: ${_signaturesExist ? '✅' : '❌'}');
        print('  - Progress: ${_progressCompleted ? '✅' : '❌'}');
      }
    } catch (e) {
      print('🔴 Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);

    return Scaffold(
      body: _buildBody(timeProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf_outlined),
            activeIcon: Icon(Icons.picture_as_pdf),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: 'Sign',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TimeProvider timeProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(timeProvider);
      case 1:
        return _buildTimeSection(timeProvider);
      case 2:
        return const DailyProgressScreen();
      case 3:
        return const WeeklyReportScreen();
      case 4:
        return const SignatureScreen();
      default:
        return _buildHomeContent(timeProvider);
    }
  }

  Widget _buildHomeContent(TimeProvider timeProvider) {
    final user = Provider.of<AuthProvider>(context).user;
    final isActive = timeProvider.hasActiveEntry;
    final isCompleted = timeProvider.timeOutValue != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absolute Choice Homecare',
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
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              Provider.of<TimeProvider>(context, listen: false).reset();
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'Caregiver'}!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormatter.getCurrentDate(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green
                                : (isCompleted ? Colors.grey : Colors.orange),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isActive
                                ? 'Active'
                                : (isCompleted ? 'Done' : 'Not Started'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Today's Summary
              Text(
                'Today\'s Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Time In',
                      value: timeProvider.timeInValue ?? '--:--',
                      icon: Icons.login,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Time Out',
                      value: timeProvider.timeOutValue ?? '--:--',
                      icon: Icons.logout,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Hours',
                      value:
                      timeProvider.totalHours?.toStringAsFixed(1) ?? '0.0',
                      icon: Icons.timer,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Status',
                      value: isActive
                          ? 'Active'
                          : (isCompleted ? 'Done' : 'Pending'),
                      icon: Icons.info,
                      color: isActive
                          ? Colors.green.shade700
                          : (isCompleted
                          ? Colors.grey
                          : Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Loading state
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // Not Started - Show Start Shift
                if (!isActive && !isCompleted)
                  HomeActionCard(
                    icon: Icons.play_arrow,
                    title: 'Start Shift',
                    subtitle: 'Begin your shift',
                    color: Colors.green.shade700,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),

                // Active Shift - Show Progress + End Shift
                if (isActive && !isCompleted)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_progressCompleted)
                        _buildStatusCard(
                          title: 'Daily Progress Completed',
                          subtitle: 'ADLs & IADLs recorded',
                          icon: Icons.assignment_turned_in,
                        )
                      else
                        HomeActionCard(
                          icon: Icons.checklist,
                          title: 'Daily Progress',
                          subtitle: 'Record ADLs & IADLs',
                          color: Colors.orange.shade700,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                          },
                        ),
                      const SizedBox(height: 8),
                      HomeActionCard(
                        icon: Icons.stop,
                        title: 'End Shift',
                        subtitle: 'Complete your shift',
                        color: Colors.red.shade700,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),

                // Shift Completed - Show all status cards
                if (isCompleted)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusCard(
                        title: 'Shift Completed',
                        subtitle: 'Data recorded successfully',
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(height: 8),
                      if (_progressCompleted)
                        _buildStatusCard(
                          title: 'Daily Progress Completed',
                          subtitle: 'ADLs & IADLs recorded',
                          icon: Icons.assignment_turned_in,
                        )
                      else
                        HomeActionCard(
                          icon: Icons.checklist,
                          title: 'Daily Progress',
                          subtitle: 'Record ADLs & IADLs',
                          color: Colors.orange.shade700,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                          },
                        ),
                      const SizedBox(height: 8),
                      if (_signaturesExist)
                        _buildStatusCard(
                          title: 'Signature Completed',
                          subtitle: 'Both parties signed',
                          icon: Icons.verified,
                        )
                      else
                        HomeActionCard(
                          icon: Icons.edit,
                          title: 'Add Signatures',
                          subtitle: 'Caregiver & Policyholder',
                          color: Colors.blue.shade700,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 4;
                            });
                          },
                        ),
                      const SizedBox(height: 8),
                      if (_progressCompleted && _signaturesExist)
                        HomeActionCard(
                          icon: Icons.picture_as_pdf,
                          title: 'View Report',
                          subtitle: 'See certification details',
                          color: Colors.purple.shade700,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                        ),

                      // ✅ FIXED: Start New Shift Button - Reset only, stay on Dashboard
                      const SizedBox(height: 8),
                      HomeActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Start New Shift',
                        subtitle: 'Begin another shift',
                        color: Colors.teal.shade700,
                        onTap: () {
                          // Reset everything for fresh shift
                          final timeProvider = Provider.of<TimeProvider>(context, listen: false);
                          final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                          final signatureProvider = Provider.of<SignatureProvider>(context, listen: false);

                          // Reset all providers
                          timeProvider.reset();
                          progressProvider.reset();
                          signatureProvider.reset();

                          // Reset local flags ONLY - Stay on Dashboard
                          setState(() {
                            _progressCompleted = false;
                            _signaturesExist = false;
                            _isLoading = false;
                            // ✅ IMPORTANT: Do NOT change _selectedIndex
                          });

                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔄 Ready for a new shift! Click "Start Shift" to begin.'),
                              backgroundColor: Colors.teal,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(TimeProvider timeProvider) {
    if (!timeProvider.hasActiveEntry && timeProvider.timeOutValue == null) {
      return const TimeInScreen();
    } else if (timeProvider.hasActiveEntry) {
      return const TimeOutScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Shift Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
          centerTitle: false,
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade100, width: 8),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Shift Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your shift data has been recorded.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildShiftDetailRow(
                        Icons.login_rounded,
                        'Time In',
                        timeProvider.timeInValue ?? '--:--',
                        Colors.blue,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildShiftDetailRow(
                        Icons.logout_rounded,
                        'Time Out',
                        timeProvider.timeOutValue ?? '--:--',
                        Colors.orange,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildShiftDetailRow(
                        Icons.timer_outlined,
                        'Total Duration',
                        '${timeProvider.totalHours?.toStringAsFixed(2)} hrs',
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Don\'t forget to add your signatures in the "Sign" tab.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 6,
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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }
}