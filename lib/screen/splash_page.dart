// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_reminder_app/login.dart';
import 'package:my_reminder_app/screen/dashboard.dart';
import 'package:my_reminder_app/widget/bottom_navigasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

// Check if user data is available in SharedPreferences
  Future<void> _checkUserLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userName = prefs.getString('userName');

    if (userId != null && userName != null) {
      // If user data is found, navigate to the Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  BottomX()),
      );
    } else {
      // If no valid user data, navigate to the Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Loading spinner while checking
      ),
    );
  }
}
