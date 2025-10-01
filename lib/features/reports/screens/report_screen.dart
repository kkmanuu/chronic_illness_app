import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:chronic_illness_app/features/auth/services/export_service.dart';
import 'package:chronic_illness_app/features/payment/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  // Static route name for navigation
  static const routeName = '/reports';
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

// State class for ReportScreen with animation capabilities
class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isExporting = false; 
  String _selectedFilter = 'All'; 
  late AnimationController _animationController; 
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Available filter options for readings
  final List<String> _filterOptions = [
    'All',
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize animations when widget is created
    _initializeAnimations();
  }

  // animation controller and animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start the animations
    _animationController.forward();
  }

  @override
  void dispose() {
    // Clean up animation controller
    _animationController.dispose();
    super.dispose();
  }

  // Filter readings based on selected time range
  List<ReadingModel> _filterReadings(List<ReadingModel> readings) {
    switch (_selectedFilter) {
      case 'Last 7 Days':
        return readings
            .where((r) => DateTime.now().difference(r.timestamp).inDays <= 7)
            .toList();
      case 'Last 30 Days':
        return readings
            .where((r) => DateTime.now().difference(r.timestamp).inDays <= 30)
            .toList();
      case 'This Month':
        final now = DateTime.now();
        return readings
            .where((r) =>
                r.timestamp.year == now.year && r.timestamp.month == now.month)
            .toList();
      default:
        return readings;
    }
  }

  // Check if user has exceeded export limit for non-premium accounts
  Future<bool> _checkExportLimit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user!.role == 'premium') return true;

    final userId = authProvider.user!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    const int maxExports = 3;

    try {
      final doc = await docRef.get();
      final data = doc.data() ?? {};
      int exportCount = data['exportCount'] ?? 0;

      if (exportCount >= maxExports) {
        // Show dialog when export limit is reached
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Export Limit Reached',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Free users are limited to 3 report exports. Upgrade to Premium for unlimited exports and advanced features!',
              style: TextStyle(color: Color(0xFF2D3748)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, PaymentScreen.routeName,
                      arguments: ReportScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking export limit: $e');
      if (mounted) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error checking export limit: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return false;
    }
  }

  // Export readings to CSV file
  Future<void> _exportReport(BuildContext context,
      {List<ReadingModel>? readings, ReadingModel? singleReading}) async {
    if (_isExporting) return;

    if ((readings == null || readings.isEmpty) && singleReading == null) {
      if (mounted) {
        // Show warning snackbar when no readings are available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text('No readings available to export'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isExporting = true;
    });

    final exportService = ExportService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      debugPrint(
          'Starting export for ${singleReading != null ? "single reading" : "${readings!.length} readings"}');
      final filePath = await exportService.exportReadingsToCSV(
          readings: readings, singleReading: singleReading);
      debugPrint('Export successful: $filePath');

      if (authProvider.user!.role != 'premium') {
        // Update export count for non-premium users
        await docRef.set(
          {
            'exportCount': FieldValue.increment(1),
            'lastExportAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      if (mounted) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Report exported to $filePath')),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
      if (mounted) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error exporting report: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // Build statistics card summarizing health metrics
  Widget _buildStatsCard(List<ReadingModel> readings) {
    if (readings.isEmpty) return const SizedBox.shrink();

    // Calculate average metrics
    final avgBloodSugar = readings.map((r) => r.bloodSugar).reduce((a, b) => a + b) / readings.length;
    final avgSystolic = readings.map((r) => r.systolicBP).reduce((a, b) => a + b) / readings.length;
    final avgDiastolic = readings.map((r) => r.diastolicBP).reduce((a, b) => a + b) / readings.length;
    
    final highReadings = readings.where((r) => r.bloodSugar > 180 || r.systolicBP > 140).length;
    final normalReadings = readings.length - highReadings;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Health Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Avg Blood Sugar',
                  '${avgBloodSugar.toStringAsFixed(1)} mg/dL',
                  Icons.water_drop_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Avg BP',
                  '${avgSystolic.toStringAsFixed(0)}/${avgDiastolic.toStringAsFixed(0)}',
                  Icons.favorite_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Readings',
                  '${readings.length}',
                  Icons.list_alt_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Normal Readings',
                  '$normalReadings',
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build individual stat item for the stats card
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Build filter chips for selecting time range
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4CAF50),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = option;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access providers for authentication and readings
    final authProvider = Provider.of<AuthProvider>(context);
    final readingProvider = Provider.of<ReadingProvider>(context);
    const primaryColor = Color(0xFF4CAF50);
    const backgroundColor = Color(0xFFF8FFFE);

    // Build the main scaffold
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with gradient and export action
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text(
              'Health Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            actions: [
              Consumer<ReadingProvider>(
                builder: (context, readingProvider, child) {
                  final filteredReadings = _filterReadings(readingProvider.readings);
                  final hasReadings = filteredReadings.isNotEmpty;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: _isExporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.file_download, color: Colors.white),
                      onPressed: hasReadings && !_isExporting
                          ? () async {
                              if (await _checkExportLimit(context)) {
                                await _exportReport(context, readings: filteredReadings);
                              }
                            }
                          : null,
                      tooltip: hasReadings ? 'Export Filtered Readings' : 'No readings to export',
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFilterChips(),
                // StreamBuilder to handle real-time reading updates
                StreamBuilder<List<ReadingModel>>(
                  stream: readingProvider.getReadingsStream(authProvider.user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading indicator
                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: primaryColor),
                              SizedBox(height: 16),
                              Text(
                                'Loading your health reports...',
                                style: TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      // Show error state
                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Error Loading Reports',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${snapshot.error}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final allReadings = snapshot.data ?? [];
                    final filteredReadings = _filterReadings(allReadings);
                    
                    if (allReadings.isEmpty) {
                      // Show empty state
                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Reports Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start tracking your health by adding your first reading',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Reading'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredReadings.isEmpty) {
                      // Show empty filter state
                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.filter_list_off,
                                size: 48,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Data for Selected Filter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different time range or add more readings',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: _buildStatsCard(filteredReadings),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // List of readings
          StreamBuilder<List<ReadingModel>>(
            stream: readingProvider.getReadingsStream(authProvider.user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final filteredReadings = _filterReadings(snapshot.data!);
              
              if (filteredReadings.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reading = filteredReadings[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _showReadingDetails(context, reading);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _getReadingStatusColor(reading).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getReadingStatusIcon(reading),
                                            color: _getReadingStatusColor(reading),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reading ${filteredReadings.length - index}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF2D3748),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  _buildMiniMetric(
                                                    'Blood Sugar',
                                                    '${reading.bloodSugar} mg/dL',
                                                    Icons.water_drop_outlined,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  _buildMiniMetric(
                                                    'BP',
                                                    '${reading.systolicBP}/${reading.diastolicBP}',
                                                    Icons.favorite_outline,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    DateFormat('MMM dd, yyyy HH:mm')
                                                        .format(reading.timestamp),
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: _isExporting
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: primaryColor,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.file_download,
                                                    color: primaryColor,
                                                    size: 20,
                                                  ),
                                            onPressed: _isExporting
                                                ? null
                                                : () async {
                                                    if (await _checkExportLimit(context)) {
                                                      await _exportReport(
                                                        context,
                                                        singleReading: reading,
                                                      );
                                                    }
                                                  },
                                            tooltip: 'Export This Reading',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredReadings.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      // Floating action button for upgrading to premium
      floatingActionButton: authProvider.user!.role != 'premium'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, PaymentScreen.routeName,
                    arguments: ReportScreen.routeName);
              },
              backgroundColor: primaryColor,
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                'Upgrade Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // Determine color based on reading status
  Color _getReadingStatusColor(ReadingModel reading) {
    final isHighBloodSugar = reading.bloodSugar > 180;
    final isLowBloodSugar = reading.bloodSugar < 70;
    final isHighBP = reading.systolicBP > 140 || reading.diastolicBP > 90;
    final isLowBP = reading.systolicBP < 90 || reading.diastolicBP < 60;

    if (isHighBloodSugar || isHighBP || isLowBloodSugar || isLowBP) {
      return Colors.red;
    }
    return Colors.green;
  }

  // Determine icon based on reading status
  IconData _getReadingStatusIcon(ReadingModel reading) {
    final isHighBloodSugar = reading.bloodSugar > 180;
    final isLowBloodSugar = reading.bloodSugar < 70;
    final isHighBP = reading.systolicBP > 140 || reading.diastolicBP > 90;
    final isLowBP = reading.systolicBP < 90 || reading.diastolicBP < 60;

    if (isHighBloodSugar || isHighBP || isLowBloodSugar || isLowBP) {
      return Icons.warning_amber_outlined;
    }
    return Icons.check_circle_outline;
  }

  // Build mini metric widget for list items
  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Show detailed bottom sheet for a reading
  void _showReadingDetails(BuildContext context, ReadingModel reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getReadingStatusColor(reading).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getReadingStatusIcon(reading),
                            color: _getReadingStatusColor(reading),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Reading Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem('Blood Sugar Level', '${reading.bloodSugar} mg/dL', Icons.water_drop),
                    const SizedBox(height: 16),
                    _buildDetailItem('Systolic BP', '${reading.systolicBP} mmHg', Icons.arrow_upward),
                    const SizedBox(height: 16),
                    _buildDetailItem('Diastolic BP', '${reading.diastolicBP} mmHg', Icons.arrow_downward),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      'Date & Time',
                      DateFormat('MMMM dd, yyyy at HH:mm').format(reading.timestamp),
                      Icons.access_time,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (await _checkExportLimit(context)) {
                          await _exportReport(context, singleReading: reading);
                        }
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text('Export This Reading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build detail item for bottom sheet
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FFFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}