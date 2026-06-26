import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare_app/providers/auth_provider.dart';
import 'package:homecare_app/providers/time_provider.dart';
import 'package:homecare_app/providers/signature_provider.dart';
import 'package:homecare_app/screens/time/time_in_screen.dart';
import 'package:homecare_app/screens/time/time_out_screen.dart';
import 'package:homecare_app/screens/progress/daily_progress_screen.dart';
import 'package:homecare_app/screens/report/weekly_report_screen.dart';
import 'package:homecare_app/screens/signature/signature_screen.dart';
import 'package:homecare_app/widgets/home_action_card.dart';
import 'package:homecare_app/core/utils/date_formatter.dart';
import 'package:homecare_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _signaturesExist = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayData();
      _checkSignaturesExist();
    });
  }

  Future<void> _loadTodayData() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final date = DateFormatter.getCurrentDate();
    await timeProvider.getTodayLog(date);
  }

  Future<void> _checkSignaturesExist() async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final signatureProvider = Provider.of<SignatureProvider>(context, listen: false);

    if (timeProvider.currentEntryId != null) {
      final response = await signatureProvider.getSignature(timeProvider.currentEntryId!);
      if (mounted) {
        setState(() {
          _signaturesExist = response.status && signatureProvider.signature != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Homecare App',
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat('Today', '24', Icons.today),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickStat('This Week', '156', Icons.weekend),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickStat('This Month', '432', Icons.calendar_month),
                    ),
                  ],
                ),
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
                  value: timeProvider.totalHours?.toStringAsFixed(1) ?? '0.0',
                  icon: Icons.timer,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Status',
                  value: isActive ? 'Active' : (isCompleted ? 'Done' : 'Pending'),
                  icon: Icons.info,
                  color: isActive ? Colors.green.shade700 : (isCompleted ? Colors.grey : Colors.orange.shade700),
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

          if (isActive && !isCompleted)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

          if (isCompleted)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeActionCard(
                  icon: Icons.picture_as_pdf,
                  title: 'Generate Report',
                  subtitle: 'View weekly report',
                  color: Colors.purple.shade700,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (!_signaturesExist)
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
                  )
                else
                  Container(
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
                          child: const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Signatures Added',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Both saved',
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
                  ),
              ],
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildTimeSection(TimeProvider timeProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!timeProvider.hasActiveEntry && timeProvider.timeOutValue == null) ...[
            // ✅ Remove LimitedBox - let TimeInScreen handle its own height
            const TimeInScreen(),
          ] else if (timeProvider.hasActiveEntry) ...[
            const TimeOutScreen(),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 40,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Shift Completed!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'In: ${timeProvider.timeInValue}  Out: ${timeProvider.timeOutValue}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      'Total: ${timeProvider.totalHours?.toStringAsFixed(2)} hrs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}