import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:chronic_illness_app/features/payment/screens/payment_screen.dart';

class AddReadingScreen extends StatefulWidget {
  static const routeName = '/add_reading';
  const AddReadingScreen({super.key});

  @override
  _AddReadingScreenState createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _bloodSugarController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  bool _isLoading = false; // Added for loading state

  late AnimationController _heroController;
  late AnimationController _formController;
  late Animation<double> _heroAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  int _currentImageIndex = 0;
  final List<String> heroImages = [
    'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg',
    'https://images.pexels.com/photos/356040/pexels-photo-356040.jpeg',
    'https://images.pexels.com/photos/263402/pexels-photo-263402.jpeg',
    'https://images.pexels.com/photos/48604/pexels-photo-48604.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startImageRotation();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    ));

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % heroImages.length;
        });
        _startImageRotation();
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _formController.dispose();
    _bloodSugarController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    super.dispose();
  }

  Future<bool> _checkReadingLimit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final readingProvider = Provider.of<ReadingProvider>(context, listen: false);
    if (authProvider.user!.role == 'premium') return true;

    final readings = await readingProvider.getReadingsStream(authProvider.user!.uid).first;
    if (readings.length >= 5) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text('Reading Limit Reached'),
            ],
          ),
          content: const Text(
            'You’ve reached the limit of 5 readings for free users. Upgrade to Premium for unlimited readings and advanced health tracking features!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, PaymentScreen.routeName, arguments: AddReadingScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Upgrade to Premium', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.1, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Image.network(
                    heroImages[_currentImageIndex],
                    key: ValueKey(_currentImageIndex),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade600,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.health_and_safety,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _heroAnimation.value)),
                    child: Opacity(
                      opacity: _heroAnimation.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health Reading',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your vital signs for better health management',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final readingProvider = Provider.of<ReadingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Health Reading'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              SlideTransition(
                position: _formSlideAnimation,
                child: FadeTransition(
                  opacity: _formFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _bloodSugarController,
                            label: 'Blood Sugar (mg/dL)',
                            hint: 'Enter blood sugar level',
                            icon: Icons.water_drop,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter blood sugar level';
                              }
                              final number = double.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < 20 || number > 500) {
                                return 'Blood sugar must be between 20 and 500 mg/dL';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _systolicBPController,
                            label: 'Systolic BP (mmHg)',
                            hint: 'Enter systolic blood pressure',
                            icon: Icons.favorite,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter systolic BP';
                              }
                              final number = int.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < 70 || number > 200) {
                                return 'Systolic BP must be between 70 and 200 mmHg';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _diastolicBPController,
                            label: 'Diastolic BP (mmHg)',
                            hint: 'Enter diastolic blood pressure',
                            icon: Icons.monitor_heart,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter diastolic BP';
                              }
                              final number = int.tryParse(value);
                              if (number == null) {
                                return 'Please enter a valid number';
                              }
                              if (number < 40 || number > 120) {
                                return 'Diastolic BP must be between 40 and 120 mmHg';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          if (authProvider.user!.role != 'premium') ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'Free users: Limited to 5 readings. Upgrade for unlimited access!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, PaymentScreen.routeName, arguments: AddReadingScreen.routeName);
                              },
                              child: const Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade700,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (!await _checkReadingLimit(context)) {
                                        return;
                                      }

                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        final reading = ReadingModel(
                                          id: const Uuid().v4(),
                                          userId: authProvider.user!.uid,
                                          bloodSugar: double.parse(_bloodSugarController.text),
                                          systolicBP: int.parse(_systolicBPController.text),
                                          diastolicBP: int.parse(_diastolicBPController.text),
                                          timestamp: DateTime.now(),
                                        );

                                        try {
                                          // Debug log
                                          await readingProvider.addReading(reading);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  SizedBox(width: 12),
                                                  Text('Reading added successfully!'),
                                                ],
                                              ),
                                              backgroundColor: Colors.green.shade600,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );

                                          // Clear form fields to allow adding another reading
                                          _bloodSugarController.clear();
                                          _systolicBPController.clear();
                                          _diastolicBPController.clear();
                                          _formKey.currentState!.reset();

                                          // Alternative: Pop the screen after a delay
                                          /*
                                          await Future.delayed(const Duration(seconds: 2));
                                          Navigator.pop(context);
                                          */
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.error, color: Colors.white),
                                                  const SizedBox(width: 12),
                                                  Text('Error: $e'),
                                                ],
                                              ),
                                              backgroundColor: Colors.red.shade600,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          'Save Reading',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
