import 'package:flutter/material.dart';
import 'package:app_kampus/auth/login_screen.dart';

void main() {
  runApp(const KampusPintarApp());
}

class KampusPintarApp extends StatelessWidget {
  const KampusPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kampus Pintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Warna background abu-abu terang
      ),
      home: const LoginScreen(),
    );
  }
}