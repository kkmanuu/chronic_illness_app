import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final DateTime time;
  final String frequency;
  final bool isTaken;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.isTaken,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> data, String id) {
    return MedicationModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      time: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequency: data['frequency'] ?? 'Daily', // Match UI case for consistency
      isTaken: data['isTaken'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'time': Timestamp.fromDate(time),
      'frequency': frequency,
      'isTaken': isTaken,
    };
  }
}