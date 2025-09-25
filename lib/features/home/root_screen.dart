import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/features/auth/screens/login_screen.dart';
import 'package:chronic_illness_app/features/home/screens/home_screen.dart';
import 'package:chronic_illness_app/features/health_tracking/screens/add_reading_screen.dart';
import 'package:chronic_illness_app/features/medication/screens/medication_schedule_screen.dart';
import 'package:chronic_illness_app/features/reports/screens/report_screen.dart';
import 'package:chronic_illness_app/features/profile/screens/profile_screen.dart';
import 'package:chronic_illness_app/features/payment/screens/payment_screen.dart';
import 'package:chronic_illness_app/core/providers/medication_provider.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';
import 'package:chronic_illness_app/features/auth/services/notification_service.dart';
import 'package:chronic_illness_app/admin/screens/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class RootScreen extends StatefulWidget {
  static const String routeName = '/root';
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => RootScreenState();
}

class RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          _selectedIndex = args;
        });
      }
      NotificationService.onNotificationTap = (payload) {
        _showMedicationDialog(payload);
      };
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializeNotifications();
  }

  void _showMedicationDialog(String medicationId) {
    final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
    final medication = medicationProvider.medications.firstWhere(
      (m) => m.id == medicationId,
      orElse: () => MedicationModel(
        id: '',
        userId: '',
        name: 'Unknown',
        dosage: '',
        time: DateTime.now(),
        frequency: 'Daily',
        isTaken: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.medication, color: Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text(
              'Medication Reminder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time to take ${medication.dosage} of ${medication.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Scheduled for ${DateFormat('HH:mm').format(medication.time)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              medicationProvider.snoozeMedication(medicationId, const Duration(minutes: 30));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder snoozed for 30 minutes')),
              );
            },
            child: const Text('Snooze', style: TextStyle(color: Color(0xFF2196F3))),
          ),
          ElevatedButton(
            onPressed: () {
              medicationProvider.updateMedicationTakenStatus(medicationId, true);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medication marked as taken')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mark as Taken', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeNotifications() {
    NotificationService().init();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FFFE),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (user.role == 'admin') {
          return _buildAdminScreen();
        } else {
          return _buildPatientScreen();
        }
      },
    );
  }

  Widget _buildPatientScreen() {
    final screens = [
      const HomeScreen(),
      const AddReadingScreen(),
      const MedicationScheduleScreen(),
      const ReportScreen(),
      const ProfileScreen(),
      const PaymentScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF4CAF50),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
            items: [
              _buildNavItem(IconlyLight.home, IconlyBold.home, 'Home', 0),
              _buildNavItem(IconlyLight.chart, IconlyBold.chart, 'Track', 1),
              _buildNavItem(IconlyLight.time_circle, IconlyBold.time_circle, 'Medications', 2),
              _buildNavItem(IconlyLight.document, IconlyBold.document, 'Reports', 3),
              _buildNavItem(IconlyLight.profile, IconlyBold.profile, 'Profile', 4),
              _buildNavItem(IconlyLight.wallet, IconlyBold.wallet, 'Payment', 5),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: isSelected ? 24 : 22,
        ),
      ),
      label: label,
    );
  }

  Widget _buildAdminScreen() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Future<void> handleLogout() async {
      try {
        await authProvider.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        }
      } catch (e) {
        debugPrint('Logout error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              authProvider.user?.username ?? 'Administrator',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
              ),
              onPressed: handleLogout,
            ),
          ),
        ],
      ),
      drawer: _buildModernDrawer(context, authProvider, handleLogout),
      body: const AdminDashboardScreen(),
    );
  }

  Widget _buildModernDrawer(BuildContext context, AuthProvider authProvider, Function handleLogout) {
    final bool isOnDashboard = ModalRoute.of(context)?.settings.name == AdminDashboardScreen.routeName;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        authProvider.user?.username?.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authProvider.user?.username ?? 'Administrator',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        authProvider.user?.role.toUpperCase() ?? 'ADMIN',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    Icons.dashboard_outlined,
                    'Dashboard',
                    () {
                      Navigator.pop(context); // Close the drawer
                      if (!isOnDashboard) {
                        Navigator.pushReplacementNamed(context, AdminDashboardScreen.routeName);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.people_outline,
                    'User Management',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AdminDashboardScreen.routeName, arguments: 0); // Users tab
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.warning_amber_outlined,
                    'Alerts & Notifications',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AdminDashboardScreen.routeName, arguments: 1); // Alerts tab
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.payment_outlined,
                    'Payments',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AdminDashboardScreen.routeName, arguments: 2); // Payments tab
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.analytics_outlined,
                    'Analytics',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AdminDashboardScreen.routeName, arguments: 3); // Reports tab
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  Icons.logout_outlined,
                  'Logout',
                  () async {
                    Navigator.pop(context);
                    await handleLogout();
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red[600] : const Color(0xFF1976D2),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isLogout ? Colors.red[600] : const Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[400],
          size: 20,
        ),
        onTap: onTap,
        hoverColor: isLogout
            ? Colors.red.withOpacity(0.05)
            : const Color(0xFF1976D2).withOpacity(0.05),
      ),
    );
  }
}
