import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing a user's health reading data.
/// Includes blood sugar, blood pressure, and timestamp details.
class ReadingModel {
  /// Unique identifier for the reading document in Firestore.
  final String id;

  /// ID of the user associated with this reading.
  final String userId;

  /// Blood sugar level reading.
  final double bloodSugar;

  /// Systolic blood pressure value (upper number).
  final int systolicBP;

  /// Diastolic blood pressure value (lower number).
  final int diastolicBP;

  /// Date and time when the reading was recorded.
  final DateTime timestamp;

  /// Constructor for initializing all required fields of the ReadingModel.
  ReadingModel({
    required this.id,
    required this.userId,
    required this.bloodSugar,
    required this.systolicBP,
    required this.diastolicBP,
    required this.timestamp,
  });

  /// Factory constructor to create a ReadingModel instance from Firestore data.
  ///
  /// [data] is a map retrieved from Firestore containing the reading details.
  /// [id] is the Firestore document ID.
  factory ReadingModel.fromMap(Map<String, dynamic> data, String id) {
    return ReadingModel(
      id: id,
      userId: data['userId'] ?? '', // Default to empty string if null
      bloodSugar: (data['bloodSugar'] ?? 0.0).toDouble(), // Ensure type is double
      systolicBP: data['systolicBP'] ?? 0, // Default to 0 if not found
      diastolicBP: data['diastolicBP'] ?? 0, // Default to 0 if not found
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the ReadingModel instance into a Map that can be
  /// stored in Firestore.
  ///
  /// Returns a map containing all the reading properties formatted correctly.
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
