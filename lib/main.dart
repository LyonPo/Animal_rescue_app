import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'core/theme/themes.dart';

import 'services/notification_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Huellitas',

      theme: AppThemes.lightTheme,

      darkTheme: AppThemes.darkTheme,

      themeMode: ThemeMode.system,

      home: FirebaseAuth.instance.currentUser != null
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
