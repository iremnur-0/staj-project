import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_id _screens/home_screen.dart';
import 'user_id _screens/login_screen.dart';
import 'user_id _screens/sign_up_screen.dart';
import 'pages/dashboard_page.dart';
import 'pages/expenses_page.dart';
import 'pages/income_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kişisel Finans Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/income': (context) => IncomeScreen(),
        '/expenses': (context) => ExpenseScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
