import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingModel {
  final String id;
  final String userId;
  final double bloodSugar;
  final int systolicBP;
  final int diastolicBP;
  final DateTime timestamp;

  ReadingModel({
    required this.id,
    required this.userId,
    required this.bloodSugar,
    required this.systolicBP,
    required this.diastolicBP,
    required this.timestamp,
  });

  factory ReadingModel.fromMap(Map<String, dynamic> data, String id) {
    return ReadingModel(
      id: id,
      userId: data['userId'] ?? '',
      bloodSugar: (data['bloodSugar'] ?? 0.0).toDouble(),
      systolicBP: data['systolicBP'] ?? 0,
      diastolicBP: data['diastolicBP'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bloodSugar': bloodSugar,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}