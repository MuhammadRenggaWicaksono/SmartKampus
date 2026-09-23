import 'package:flutter/material.dart';

class PresensiScreen extends StatelessWidget {
  const PresensiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Presensi Kuliah', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gpp_bad_outlined, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text('Presensi tidak dapat ditampilkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                child: const Column(
                  children: [
                    Text('Saat ini belum memasuki perkuliahan.', style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    Text('Event type: unauthorize view\nPage: Lihat Presensi Kuliah', style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}