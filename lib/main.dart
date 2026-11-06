
import 'package:flutter/material.dart';
import 'package:marketplace_hewan_peliharaan/screens/category_test_page.dart';
import 'package:marketplace_hewan_peliharaan/screens/product_list_page.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6E63),
        ),
        scaffoldBackgroundColor:
        const Color(0xFFF5F0E8),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
