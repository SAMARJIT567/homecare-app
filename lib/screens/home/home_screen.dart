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
        title: const Text('Homecare App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
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

  // ✅ Using ListView instead of Column
  Widget _buildHomeContent(TimeProvider timeProvider) {
    final user = Provider.of<AuthProvider>(context).user;
    final isActive = timeProvider.hasActiveEntry;
    final isCompleted = timeProvider.timeOutValue != null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      physics: const BouncingScrollPhysics(),
      children: [
        // Welcome Section
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.name ?? 'Caregiver'}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatter.getCurrentDate(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : (isCompleted ? Colors.grey : Colors.orange),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isActive ? '🟢 Active' : (isCompleted ? '⏹️ Done' : '⚪ Not Started'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Quick Stats
        Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 5),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'In',
                timeProvider.timeInValue ?? '--:--',
                Icons.login,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildStatCard(
                'Out',
                timeProvider.timeOutValue ?? '--:--',
                Icons.logout,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hours',
                timeProvider.totalHours?.toStringAsFixed(1) ?? '0.0',
                Icons.timer,
                Colors.green,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildStatCard(
                'Status',
                isActive ? 'Active' : (isCompleted ? 'Done' : 'Pending'),
                Icons.info,
                isActive ? Colors.green : (isCompleted ? Colors.grey : Colors.orange),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Quick Actions
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 5),

        if (!isActive && !isCompleted)
          HomeActionCard(
            icon: Icons.play_arrow,
            title: 'Start Shift',
            subtitle: 'Time In',
            color: Colors.green,
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
                subtitle: 'ADLs & IADLs',
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              const SizedBox(height: 5),
              HomeActionCard(
                icon: Icons.stop,
                title: 'End Shift',
                subtitle: 'Time Out',
                color: Colors.red,
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
                subtitle: 'View report',
                color: Colors.purple,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              const SizedBox(height: 5),
              if (!_signaturesExist)
                HomeActionCard(
                  icon: Icons.edit,
                  title: 'Add Signatures',
                  subtitle: 'Caregiver & Policyholder',
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✅ Signatures Added',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Both signatures saved',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!timeProvider.hasActiveEntry && timeProvider.timeOutValue == null) ...[
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
                    const SizedBox(height: 6),
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