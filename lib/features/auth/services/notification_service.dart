
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chronic_illness_app/core/models/medication_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static Function(String)? onNotificationTap;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          onNotificationTap?.call(response.payload!);
        }
      },
    );
  }

  Future<void> scheduleMedicationNotification(MedicationModel medication) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime;

    // Calculate the next notification time based on frequency
    if (medication.frequency.toLowerCase() == 'daily') {
      scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        medication.time.hour,
        medication.time.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    } else if (medication.frequency.toLowerCase() == 'weekly') {
      // Schedule for the same weekday as medication.time
      int targetWeekday = medication.time.weekday;
      int daysUntilTarget = (targetWeekday - now.weekday + 7) % 7;
      if (daysUntilTarget == 0 && tz.TZDateTime(tz.local, now.year, now.month, now.day, medication.time.hour, medication.time.minute).isBefore(now)) {
        daysUntilTarget = 7;
      }
      scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        medication.time.hour,
        medication.time.minute,
      ).add(Duration(days: daysUntilTarget));
    } else {
      // Monthly: Schedule for the same day of month as medication.time
      int targetDay = medication.time.day;
      DateTime nextMonth = DateTime(now.year, now.month, targetDay);
      if (nextMonth.isBefore(now.toLocal())) {
        nextMonth = DateTime(now.year, now.month + 1, targetDay);
      }
      scheduledTime = tz.TZDateTime.from(
        DateTime(nextMonth.year, nextMonth.month, nextMonth.day, medication.time.hour, medication.time.minute),
        tz.local,
      );
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medication.id.hashCode, // Use medication ID as notification ID
      'Medication Reminder: ${medication.name}',
      'Time to take ${medication.dosage} of ${medication.name}',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: medication.frequency.toLowerCase() == 'daily'
          ? DateTimeComponents.time
          : medication.frequency.toLowerCase() == 'weekly'
              ? DateTimeComponents.dayOfWeekAndTime
              : DateTimeComponents.dayOfMonthAndTime,
      payload: medication.id,
    );
  }

  Future<void> cancelNotification(String medicationId) async {
    await _flutterLocalNotificationsPlugin.cancel(medicationId.hashCode);
  }
}
