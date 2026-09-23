import 'package:flutter/material.dart';

class GantiPasswordWifiScreen extends StatelessWidget {
  const GantiPasswordWifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password Wifi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: const Center(child: Text('Formulir Ganti Password Wifi Kampus')),
    );
  }
}