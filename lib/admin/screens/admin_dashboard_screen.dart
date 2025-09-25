import 'package:chronic_illness_app/admin/screens/user_management_screen.dart';
import 'package:chronic_illness_app/admin/screens/alerts_screen.dart';
import 'package:chronic_illness_app/admin/screens/payment_management_screen.dart';
import 'package:chronic_illness_app/admin/screens/admin_profile_edit_screen.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin_dashboard';
  final int initialTab;

  const AdminDashboardScreen({super.key, this.initialTab = 0});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null || authProvider.user!.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Access denied. Admins only.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      });
      return;
    }

    try {
      // Add timeout to prevent indefinite loading
      await FirebaseFirestore.instance.collection('users').limit(1).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firestore query timed out');
        },
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying admin access: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor.withOpacity(0.1), bgColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28, semanticLabel: title),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading analytics data...', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }
        if (userSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error fetching users: ${userSnapshot.error}',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No users found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        final users = userSnapshot.data!.docs;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('readings').snapshots(),
          builder: (context, readingSnapshot) {
            if (readingSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading readings data...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            final readings = readingSnapshot.data?.docs ?? [];
            final totalUsers = users.length;
            final activeUsers = users.where((u) {
              final data = u.data() as Map<String, dynamic>;
              return data['isActive'] as bool? ?? false;
            }).length;
            final totalReadings = readings.length;
            final avgReadingsPerUser = totalUsers > 0 ? (totalReadings / totalUsers).toStringAsFixed(1) : '0.0';

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.blue.shade600, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Analytics Overview',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStatCard(
                      title: 'Total Users',
                      value: totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue.shade600,
                      bgColor: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Active Users',
                      value: activeUsers.toString(),
                      icon: Icons.person_outline,
                      color: Colors.green.shade600,
                      bgColor: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Total Readings',
                      value: totalReadings.toString(),
                      icon: Icons.monitor_heart,
                      color: Colors.red.shade600,
                      bgColor: Colors.red,
                    ),
                    _buildStatCard(
                      title: 'Avg Readings per User',
                      value: avgReadingsPerUser,
                      icon: Icons.trending_up,
                      color: Colors.purple.shade600,
                      bgColor: Colors.purple,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DrawerHeader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AdminProfileEditScreen.routeName);
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null
                        ? const Icon(Icons.admin_panel_settings, size: 32, color: Colors.blue)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.username ?? 'Admin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Administrator',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (_isLoading || authProvider.user == null || authProvider.user!.role != 'admin') {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verifying admin access...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.blue.shade700,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AdminProfileEditScreen.routeName);
              },
              icon: const Icon(Icons.person),
              tooltip: 'Edit Profile',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade600],
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.people, size: 24),
                    text: 'Users',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.notifications_active, size: 24),
                    text: 'Alerts',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.payment, size: 24),
                    text: 'Payments',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.analytics, size: 24),
                    text: 'Reports',
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildProfileHeader(authProvider),
                _buildDrawerItem(Icons.people, 'Users', 0),
                _buildDrawerItem(Icons.notifications_active, 'Alerts', 1),
                _buildDrawerItem(Icons.payment, 'Payments', 2),
                _buildDrawerItem(Icons.analytics, 'Reports', 3),
                const Divider(height: 30),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.green, semanticLabel: 'Edit Profile'),
                  ),
                  title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AdminProfileEditScreen.routeName);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout, color: Colors.red, semanticLabel: 'Logout'),
                  ),
                  title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () async {
                    await authProvider.signOut();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const UserManagementScreen(),
            const AlertsScreen(),
            const PaymentManagementScreen(),
            _buildReportsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue.shade700, semanticLabel: title),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        _tabController.animateTo(index);
        Navigator.pop(context);
      },
    );
  }
}