import 'package:flutter/material.dart';

class TranskripScreen extends StatelessWidget {
  const TranskripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Transkrip Nilai', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 80, color: Colors.purple.shade200),
            const SizedBox(height: 16),
            const Text('Transkrip Kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Riwayat nilai Anda akan muncul di sini.', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}