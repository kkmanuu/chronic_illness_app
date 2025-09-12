import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:chronic_illness_app/admin/widgets/alert_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _thresholdFormKey = GlobalKey<FormState>();
  final _bloodSugarController = TextEditingController(text: '180');
  final _systolicBPController = TextEditingController(text: '140');
  final _diastolicBPController = TextEditingController(text: '90');

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  void _loadThresholds() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('thresholds').get();
      if (doc.exists) {
        setState(() {
          _bloodSugarController.text = doc.data()?['bloodSugar']?.toString() ?? '180';
          _systolicBPController.text = doc.data()?['systolicBP']?.toString() ?? '140';
          _diastolicBPController.text = doc.data()?['diastolicBP']?.toString() ?? '90';
        });
      }
    } catch (e) {
      _showSnackBar('Error loading thresholds: $e', Colors.orange);
    }
  }

  @override
  void dispose() {
    _bloodSugarController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    super.dispose();
  }

  Widget _buildThresholdField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Required';
          if (double.tryParse(value!) == null) return 'Invalid number';
          return null;
        },
        decoration: InputDecoration(
          labelText: '$label ($unit)',
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: iconColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildThresholdForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _thresholdFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tune, color: Colors.orange.shade600, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alert Thresholds',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildThresholdField(
              controller: _bloodSugarController,
              label: 'Blood Sugar',
              unit: 'mg/dL',
              icon: Icons.water_drop,
              iconColor: Colors.blue.shade600,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildThresholdField(
                    controller: _systolicBPController,
                    label: 'Systolic BP',
                    unit: 'mmHg',
                    icon: Icons.favorite,
                    iconColor: Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThresholdField(
                    controller: _diastolicBPController,
                    label: 'Diastolic BP',
                    unit: 'mmHg',
                    icon: Icons.monitor_heart,
                    iconColor: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveThresholds,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text('Save Thresholds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveThresholds() async {
    if (_thresholdFormKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('settings').doc('thresholds').set({
          'bloodSugar': double.parse(_bloodSugarController.text),
          'systolicBP': int.parse(_systolicBPController.text),
          'diastolicBP': int.parse(_diastolicBPController.text),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showSnackBar('Thresholds updated successfully', Colors.green);
      } catch (e) {
        _showSnackBar('Error saving thresholds: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingProvider = Provider.of<ReadingProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          _buildThresholdForm(),
          Expanded(
            child: StreamBuilder<List<ReadingModel>>(
              stream: readingProvider.getAllReadingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error fetching alerts',
                          style: TextStyle(color: Colors.red.shade600, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('No alerts found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final readings = snapshot.data!;
                final thresholds = {
                  'bloodSugar': double.tryParse(_bloodSugarController.text) ?? 180.0,
                  'systolicBP': (int.tryParse(_systolicBPController.text) ?? 140).toDouble(),
                  'diastolicBP': (int.tryParse(_diastolicBPController.text) ?? 90).toDouble(),
                };

                final abnormalReadings = readings.where((r) {
                  return (r.bloodSugar ?? 0) > thresholds['bloodSugar']! ||
                      (r.systolicBP ?? 0) > thresholds['systolicBP']! ||
                      (r.diastolicBP ?? 0) > thresholds['diastolicBP']!;
                }).toList();

                if (abnormalReadings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                        const SizedBox(height: 16),
                        const Text('No critical alerts', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('All readings are within normal ranges', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade600, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Critical Alerts (${abnormalReadings.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: abnormalReadings.length,
                        itemBuilder: (context, index) {
                          final reading = abnormalReadings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: AlertCard(reading: reading, thresholds: thresholds),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}