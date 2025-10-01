import 'package:flutter/material.dart';

// Auth
import 'package:chronic_illness_app/features/auth/screens/login_screen.dart';
import 'package:chronic_illness_app/features/auth/screens/register_screen.dart';
import 'package:chronic_illness_app/features/auth/screens/forgot_password_screen.dart';

// Home & Root
import 'package:chronic_illness_app/features/home/screens/home_screen.dart';
import 'package:chronic_illness_app/features/home/root_screen.dart';

// Profile
import 'package:chronic_illness_app/features/profile/screens/profile_screen.dart';

// Health Tracking
import 'package:chronic_illness_app/features/health_tracking/screens/add_reading_screen.dart';

// Medications
import 'package:chronic_illness_app/features/medication/screens/medication_schedule_screen.dart';

// Reports
import 'package:chronic_illness_app/features/reports/screens/report_screen.dart';

// Admin
import 'package:chronic_illness_app/admin/screens/admin_dashboard_screen.dart';
import 'package:chronic_illness_app/admin/screens/admin_profile_edit_screen.dart';

// Payments
import 'package:chronic_illness_app/features/payment/screens/payment_screen.dart';

// Help & Support
import 'package:chronic_illness_app/features/help/screens/help_center_screen.dart';
import 'package:chronic_illness_app/features/help/screens/feedback_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/home';
  static const String root = '/root';
  static const String profile = '/profile';
  static const String addReading = '/add_reading';
  static const String medications = '/medications';
  static const String payment = '/payment';
  static const String reports = '/reports';
  static const String adminDashboard = '/admin_dashboard';
  static const String adminProfileEdit = '/admin_profile_edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      root: (context) => const RootScreen(),
      profile: (context) => const ProfileScreen(),
      addReading: (context) => const AddReadingScreen(),
      medications: (context) => const MedicationScheduleScreen(),
      HelpCenterScreen.routeName: (context) => const HelpCenterScreen(),
      FeedbackScreen.routeName: (context) => const FeedbackScreen(),
      reports: (context) => const ReportScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminProfileEdit: (context) => const AdminProfileEditScreen(),
      payment: (context) => const PaymentScreen(),
    };
  }
}