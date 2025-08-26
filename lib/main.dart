import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/constants.dart';

import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Notifications
  await NotificationService.init();

  runApp(const DocTimeApp());
}

class DocTimeApp extends StatelessWidget {
  const DocTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(), // 🚀 نبدأ مع SplashScreen
    );
  }
}
