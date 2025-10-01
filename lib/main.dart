import 'package:chronic_illness_app/config/theme.dart';
import 'package:chronic_illness_app/config/routes.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/core/providers/medication_provider.dart';
import 'package:chronic_illness_app/core/providers/payment_provider.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:chronic_illness_app/features/auth/screens/login_screen.dart';
import 'package:chronic_illness_app/features/home/root_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'firebase_options.dart';
import 'package:chronic_illness_app/features/auth/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set M-PESA credentials for sandbox
  MpesaFlutterPlugin.setConsumerKey('KHbuxkY9tijH9lG1NgCKHqWheaA6vhMOGzKuvauPHzBPGwXH');
  MpesaFlutterPlugin.setConsumerSecret('9Nsg8zZ98IhAAFMZGnq6rCNHC6c9eFtGlYCpGv6POboQFgy2re2hK5LJw923Gog4');

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadCurrentUser()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chronic Illness App',
            theme: appTheme,
            home: authProvider.user == null
                ? const LoginScreen()
                : const RootScreen(),
            routes: AppRoutes.getRoutes(),
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
