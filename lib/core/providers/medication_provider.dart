import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';
import 'package:chronic_illness_app/features/auth/services/notification_service.dart';
import 'package:flutter/foundation.dart';


class MedicationProvider with ChangeNotifier {
  // Local list of medications for quick access in the app
  List<MedicationModel> _medications = [];

  // Getter to expose medications safely
  List<MedicationModel> get medications => _medications;

  /// Fetches medications as a live stream from Firestore for a specific user.
  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .snapshots() // listen to live changes
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            // Convert Firestore document into a MedicationModel
            return MedicationModel.fromMap(doc.data(), doc.id);
          } catch (e) {
            debugPrint('Error parsing medication document ${doc.id}: $e');
            return null; // Skip malformed documents instead of crashing
          }
        }).where((med) => med != null).cast<MedicationModel>().toList();
      }).handleError((error) {
        debugPrint('Error in medication stream: $error');
        throw error; // Pass error to StreamBuilder
      });
    } catch (e) {
      debugPrint('Error setting up medication stream: $e');
      rethrow;
    }
  }

  /// Adds a new medication to Firestore and local state.
  /// Also schedules a notification reminder for this medication.
  Future<void> addMedication(MedicationModel medication) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medication.id)
          .set(medication.toMap());
      _medications.add(medication);

      // Schedule a reminder notification for the medication
      await NotificationService().scheduleMedicationNotification(medication);

      notifyListeners(); // Notify UI about state change
    } catch (e) {
      debugPrint('Error adding medication: $e');
      rethrow;
    }
  }

  /// Updates the 'isTaken' status of a medication.
  /// If taken, cancel and reschedule the notification for the next time.
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
          // Cancel the old notification and reschedule
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

  /// Snoozes a medication reminder by delaying it with the given duration.
  /// Updates both Firestore and local state, and reschedules the notification.
  Future<void> snoozeMedication(String medicationId, Duration duration) async {
    try {
      final medication = _medications.firstWhere((m) => m.id == medicationId);

      // Calculate new reminder time
      final newTime = medication.time.add(duration);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId)
          .update({'time': Timestamp.fromDate(newTime)});

      // Update local list
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

        // Cancel old notification and set a new one
        await NotificationService().cancelNotification(medicationId);
        await NotificationService().scheduleMedicationNotification(_medications[index]);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error snoozing medication: $e');
      rethrow;
    }
  }

  /// Utility method to check if Firestore connection is working.
  /// Returns true if the app can fetch at least one document.
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
