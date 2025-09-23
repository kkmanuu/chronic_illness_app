import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';
import 'package:chronic_illness_app/features/auth/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class MedicationProvider with ChangeNotifier {
  List<MedicationModel> _medications = [];

  List<MedicationModel> get medications => _medications;

  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return MedicationModel.fromMap(doc.data(), doc.id);
          } catch (e) {
            debugPrint('Error parsing medication document ${doc.id}: $e');
            return null; // Skip malformed documents
          }
        }).where((med) => med != null).cast<MedicationModel>().toList();
      }).handleError((error) {
        debugPrint('Error in medication stream: $error');
        throw error; // Let StreamBuilder handle the error
      });
    } catch (e) {
      debugPrint('Error setting up medication stream: $e');
      rethrow;
    }
  }

  Future<void> addMedication(MedicationModel medication) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medication.id)
          .set(medication.toMap());
      _medications.add(medication);
      await NotificationService().scheduleMedicationNotification(medication);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding medication: $e');
      rethrow;
    }
  }

  Future<void> updateMedicationTakenStatus(String medicationId, bool isTaken) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .update({'isTaken': isTaken});
      final index = _medications.indexWhere((m) => m.id == medicationId);
      if (index != -1) {
        _medications[index] = MedicationModel(
          id: _medications[index].id,
          userId: _medications[index].userId,
          name: _medications[index].name,
          dosage: _medications[index].dosage,
          time: _medications[index].time,
          frequency: _medications[index].frequency,
          isTaken: isTaken,
        );
        if (isTaken) {
          await NotificationService().cancelNotification(medicationId);
          await NotificationService().scheduleMedicationNotification(_medications[index]);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating medication status: $e');
      rethrow;
    }
  }

  Future<void> snoozeMedication(String medicationId, Duration duration) async {
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);
      final newTime = medication.time.add(duration);
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .update({'time': Timestamp.fromDate(newTime)});
      final index = _medications.indexWhere((m) => m.id == medicationId);
      if (index != -1) {
        _medications[index] = MedicationModel(
          id: medication.id,
          userId: medication.userId,
          name: medication.name,
          dosage: medication.dosage,
          time: newTime,
          frequency: medication.frequency,
          isTaken: medication.isTaken,
        );
        await NotificationService().cancelNotification(medicationId);
        await NotificationService().scheduleMedicationNotification(_medications[index]);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error snoozing medication: $e');
      rethrow;
    }
  }

  // New method to check Firestore connectivity
  Future<bool> checkFirestoreConnectivity() async {
    try {
      await FirebaseFirestore.instance.collection('medications').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('Firestore connectivity check failed: $e');
      return false;
    }
  }
}