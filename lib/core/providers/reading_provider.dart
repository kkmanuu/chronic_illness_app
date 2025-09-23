import 'package:chronic_illness_app/features/auth/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:chronic_illness_app/core/models/reading_model.dart';


class ReadingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final List<ReadingModel> _readings = [];

  List<ReadingModel> get readings => _readings;

  Future<void> addReading(ReadingModel reading) async {
    await _firestoreService.addReading(reading);
    notifyListeners();
  }

  Stream<List<ReadingModel>> getReadingsStream(String userId) {
    return _firestoreService.getReadings(userId);
  }

  Stream<List<ReadingModel>> getAllReadingsStream() {
    return _firestoreService.getAllReadings();
  }
}
