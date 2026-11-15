import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GeoVectorApp());
}

class GeoVectorApp extends StatelessWidget {
  const GeoVectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoVector',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
