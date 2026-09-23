import 'package:flutter/material.dart';

class KhsScreen extends StatelessWidget {
  const KhsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kartu Hasil Studi (KHS)', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 80, color: Colors.green.shade200),
            const SizedBox(height: 16),
            const Text('Data KHS Belum Tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Nilai semester ini belum dipublikasikan.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}