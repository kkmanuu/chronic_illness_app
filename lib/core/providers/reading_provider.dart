import 'package:chronic_illness_app/features/auth/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:chronic_illness_app/core/models/reading_model.dart';

class ReadingProvider with ChangeNotifier {
  // Service to interact with Firestore
  final FirestoreService _firestoreService = FirestoreService();

  // Local list of readings (not always used directly)
  final List<ReadingModel> _readings = [];

  // Getter for readings
  List<ReadingModel> get readings => _readings;

  // Add a new reading to Firestore
  Future<void> addReading(ReadingModel reading) async {
    await _firestoreService.addReading(reading);
    notifyListeners();
  }

  // Stream of readings for a specific user
  Stream<List<ReadingModel>> getReadingsStream(String userId) {
    return _firestoreService.getReadings(userId);
  }

  // Stream of all readings (for admin/overview use)
  Stream<List<ReadingModel>> getAllReadingsStream() {
    return _firestoreService.getAllReadings();
  }
}
