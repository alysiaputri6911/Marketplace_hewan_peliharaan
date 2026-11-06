
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_logo.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userRole = prefs.getString('userRole');
      final userData = prefs.getString('userData');

      Widget nextPage;

      if (isLoggedIn && userRole == 'customer') {
        nextPage = const HomePage();
      } else if (isLoggedIn &&
          userRole == 'admin' &&
          userData != null) {
        final user = jsonDecode(userData) as Map<String, dynamic>;
        nextPage = AdminDashboard(user: user);
      } else {
        // Jika data login tidak lengkap, kembali ke login.
        await prefs.setBool('isLoggedIn', false);
        nextPage = const LoginPage();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => nextPage,
        ),
      );
    } catch (e) {
      debugPrint('Gagal memeriksa status login: $e');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'images/logo_marketplace.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('PENYEBAB ERROR LOGO: $error');
                  return const Center(
                    child: Text(
                      'LOGO TIDAK DITEMUKAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'PET MARKETPLACE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Semua kebutuhan hewan kesayanganmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 35),
            const CircularProgressIndicator(
              color: Color(0xFF8D6E63),
            ),
          ],
        ),
      ),
    );
  }
}
