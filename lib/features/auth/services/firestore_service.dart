import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReading(ReadingModel reading) async {
    await _firestore.collection('readings').add(reading.toMap());
  }

  Stream<List<ReadingModel>> getReadings(String userId) {
    return _firestore
        .collection('readings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReadingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ReadingModel>> getAllReadings() {
    return _firestore
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReadingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMedication(MedicationModel medication) async {
    await _firestore.collection('medications').add(medication.toMap());
  }

  Stream<List<MedicationModel>> getMedications(String userId) {
    return _firestore
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .orderBy('time')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
