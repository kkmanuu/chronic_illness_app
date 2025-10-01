import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertCard extends StatelessWidget {
  final ReadingModel reading;
  final Map<String, double> thresholds;

  const AlertCard({super.key, required this.reading, required this.thresholds});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text('User ID: ${reading.userId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Sugar: ${reading.bloodSugar?.toStringAsFixed(1) ?? 'N/A'} mg/dL${(reading.bloodSugar ?? 0) > thresholds['bloodSugar']! ? ' (High)' : ''}',
            ),
            Text(
              'Systolic BP: ${reading.systolicBP?.toString() ?? 'N/A'} mmHg${(reading.systolicBP ?? 0) > thresholds['systolicBP']! ? ' (High)' : ''}',
            ),
            Text(
              'Diastolic BP: ${reading.diastolicBP?.toString() ?? 'N/A'} mmHg${(reading.diastolicBP ?? 0) > thresholds['diastolicBP']! ? ' (High)' : ''}',
            ),
            Text(
              'Time: ${reading.timestamp != null ? DateFormat.yMMMd().add_jm().format(reading.timestamp!) : 'N/A'}',
            ),
          ],
        ),
        trailing: const Icon(Icons.warning, color: Colors.red),
      ),
    );
  }
}
