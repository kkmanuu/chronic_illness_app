import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:chronic_illness_app/core/providers/medication_provider.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/features/home/widgets/health_card.dart';
import 'package:chronic_illness_app/features/home/widgets/trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronic_illness_app/config/routes.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentImageIndex = 0;

  // List of hero images with headings
  final List<Map<String, String>> heroImages = [
    {
      'url': 'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg',
      'heading': 'Health Tracking'
    },
    {
      'url': 'https://images.pexels.com/photos/356040/pexels-photo-356040.jpeg',
      'heading': 'Wellness Journey'
    },
    {
      'url': 'https://images.pexels.com/photos/263402/pexels-photo-263402.jpeg',
      'heading': 'Daily Progress'
    },
    {
      'url': 'https://images.pexels.com/photos/48604/pexels-photo-48604.jpeg',
      'heading': 'Medical Care'
    },
    {
      'url': 'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
      'heading': 'Healthy Living'
    },
    {
      'url': 'https://images.pexels.com/photos/164455/pexels-photo-164455.jpeg',
      'heading': 'Treatment Plan'
    },
    {
      'url': 'https://images.pexels.com/photos/3938022/pexels-photo-3938022.jpeg',
      'heading': 'Health Monitoring'
    },
    {
      'url': 'https://images.pexels.com/photos/3845810/pexels-photo-3845810.jpeg',
      'heading': 'Care Management'
    },
    {
      'url': 'https://images.pexels.com/photos/5726706/pexels-photo-5726706.jpeg',
      'heading': 'Wellbeing Focus'
    },
    {
      'url': 'https://images.pexels.com/photos/6129507/pexels-photo-6129507.jpeg',
      'heading': 'Health Goals'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController for fade in/out effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3 seconds for each image
    )..repeat(reverse: false);

    // Define fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Change image every 5 seconds
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % heroImages.length;
        });
        _animationController.forward();
      }
    });

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final readingProvider = Provider.of<ReadingProvider>(context);
    final medicationProvider = Provider.of<MedicationProvider>(context);

    const primaryColor = Color(0xFF4CAF50);
    const secondaryColor = Color(0xFF81C784);
    const backgroundColor = Color(0xFFF8FFFE);
    const cardColor = Colors.white;
    const accentColor = Color(0xFF2196F3);

    if (authProvider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Fading background images
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: CachedNetworkImage(
                          imageUrl: heroImages[_currentImageIndex]['url']!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Image heading text
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            heroImages[_currentImageIndex]['heading']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Image indicator dots
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Row(
                      children: List.generate(heroImages.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  authProvider.user?.username ?? "User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: authProvider.user?.profileImageUrl != null
                        ? NetworkImage(authProvider.user!.profileImageUrl!)
                        : null,
                    child: authProvider.user?.profileImageUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 26)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Daily Health Snapshot', Icons.health_and_safety_outlined),
                const SizedBox(height: 12),
                StreamBuilder<List<ReadingModel>>(
                  stream: readingProvider.getReadingsStream(authProvider.user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCard();
                    }
                    if (snapshot.hasError) {
                      return _buildErrorCard('Failed to load health snapshot');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyCard(
                        'No Readings Yet',
                        'Add your first reading to see your health stats',
                        Icons.add_chart_outlined,
                      );
                    }
                    final reading = snapshot.data!.firstWhere(
                      (r) => DateTime.now().difference(r.timestamp).inDays == 0,
                      orElse: () => snapshot.data!.first,
                    );
                    return _buildHealthSnapshotCard(context, reading);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Today\'s Medications', Icons.medication_outlined),
                const SizedBox(height: 12),
                StreamBuilder<List<MedicationModel>>(
                  stream: medicationProvider.getMedicationsStream(authProvider.user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCard();
                    }
                    if (snapshot.hasError) {
                      return _buildErrorCard('Failed to load medications');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyCard(
                        'No Medications',
                        'Add medications to set up reminders',
                        Icons.medical_services_outlined,
                      );
                    }
                    final todayMedications = snapshot.data!
                        .where((m) => DateTime.now().difference(m.time).inDays == 0)
                        .toList();
                    return Column(
                      children: todayMedications
                          .map((medication) => _buildMedicationCard(context, medication, medicationProvider))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Health Insights', Icons.trending_up_outlined),
                const SizedBox(height: 12),
                _buildHealthInsights(context, readingProvider, authProvider.user!.uid),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Quick Actions', Icons.touch_app_outlined),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
        child: CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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

  Widget _buildEmptyCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildHealthSnapshotCard(BuildContext context, ReadingModel reading) {
    final isHighBloodSugar = reading.bloodSugar > 180;
    final isLowBloodSugar = reading.bloodSugar < 70;
    final isHighBP = reading.systolicBP > 140 || reading.diastolicBP > 90;
    final isLowBP = reading.systolicBP < 90 || reading.diastolicBP < 60;

    String statusText = 'Normal';
    IconData statusIcon = Icons.check_circle_outline;
    Color statusColor = Colors.green;

    if (isHighBloodSugar || isHighBP) {
      statusText = 'Warning: High Reading';
      statusIcon = Icons.warning_amber_outlined;
      statusColor = Colors.red;
    } else if (isLowBloodSugar || isLowBP) {
      statusText = 'Warning: Low Reading';
      statusIcon = Icons.warning_amber_outlined;
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric('Blood Sugar', '${reading.bloodSugar} mg/dL'),
              const SizedBox(width: 16),
              _buildMetric('BP', '${reading.systolicBP}/${reading.diastolicBP}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, HH:mm').format(reading.timestamp),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (statusText.contains('Warning'))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  _sendEmergencyEmail(context);
                },
                icon: const Icon(Icons.emergency, size: 18),
                label: const Text('Contact Emergency'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, MedicationModel medication, MedicationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetric('Dosage', medication.dosage),
                    const SizedBox(width: 16),
                    _buildMetric('Time', DateFormat('HH:mm').format(medication.time)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      medication.isTaken ? Icons.check_circle : Icons.circle_outlined,
                      color: medication.isTaken ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medication.isTaken ? 'Taken' : 'Not Taken',
                      style: TextStyle(
                        color: medication.isTaken ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  provider.updateMedicationTakenStatus(medication.id, !medication.isTaken);
                },
              ),
              IconButton(
                icon: const Icon(Icons.snooze, color: Colors.blue),
                onPressed: () {
                  provider.snoozeMedication(medication.id, const Duration(minutes: 30));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights(BuildContext context, ReadingProvider readingProvider, String userId) {
    return StreamBuilder<List<ReadingModel>>(
      stream: readingProvider.getReadingsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load insights');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard('No Insights', 'Add more readings for insights', Icons.insights);
        }

        final readings = snapshot.data!;
        final last7Days = readings.where((r) => DateTime.now().difference(r.timestamp).inDays <= 7).toList();
        if (last7Days.isEmpty) {
          return _buildEmptyCard('No Recent Data', 'Add recent readings for insights', Icons.insights);
        }

        final avgBloodSugar = last7Days.map((r) => r.bloodSugar).reduce((a, b) => a + b) / last7Days.length;
        final avgSystolicBP = last7Days.map((r) => r.systolicBP).reduce((a, b) => a + b) / last7Days.length;
        final avgDiastolicBP = last7Days.map((r) => r.diastolicBP).reduce((a, b) => a + b) / last7Days.length;

        String trendText = 'Stable';
        if (last7Days.length >= 2) {
          final recent = last7Days.first.bloodSugar;
          final older = last7Days.last.bloodSugar;
          if (recent < older * 0.9) {
            trendText = 'Improving';
          } else if (recent > older * 1.1) {
            trendText = 'Worsening';
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.insights, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Weekly Health Insights',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMetric('Avg. Blood Sugar', '${avgBloodSugar.toStringAsFixed(1)} mg/dL'),
              const SizedBox(height: 8),
              _buildMetric('Avg. BP', '${avgSystolicBP.toStringAsFixed(1)}/${avgDiastolicBP.toStringAsFixed(1)} mmHg'),
              const SizedBox(height: 8),
              Text(
                'Trend: $trendText',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: trendText == 'Improving'
                      ? Colors.green
                      : trendText == 'Worsening'
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: TrendChart(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Streak: ${last7Days.length} days of consistent logging 🎉',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep logging daily to maintain your streak!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: Icons.add_chart,
            label: 'Add Reading',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addReading),
          ),
          _buildActionButton(
            context,
            icon: Icons.file_download,
            label: 'Export Report',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.reports);
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.emergency,
            label: 'Emergency',
            onPressed: () {
              _sendEmergencyEmail(context);
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.payment,
            label: 'Upgrade Plan',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.root,
                (route) => false,
                arguments: 5,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF4CAF50)),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmergencyEmail(BuildContext context) async {
    final email = 'emmanuelrono7868@gmail.com';
    final subject = 'EMERGENCY: Health Alert - Urgent Attention Required';
    final body = '''
URGENT: Health Emergency Alert

This is an automated emergency alert from the Chronic Illness Management App.

User: ${Provider.of<AuthProvider>(context, listen: false).user?.username ?? 'Unknown User'}
Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}

CRITICAL HEALTH READING DETECTED:

The user's recent health readings have triggered an emergency alert. 
Immediate medical attention may be required.

Please contact the user immediately and provide necessary assistance.

This is an automated emergency notification.
''';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      // Silently handle the error without showing a SnackBar
    }
  }
}
