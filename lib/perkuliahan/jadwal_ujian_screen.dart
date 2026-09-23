import 'package:flutter/material.dart';

class JadwalUjianScreen extends StatefulWidget {
  const JadwalUjianScreen({Key? key}) : super(key: key);

  @override
  State<JadwalUjianScreen> createState() => _JadwalUjianScreenState();
}

class _JadwalUjianScreenState extends State<JadwalUjianScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Jadwal Ujian', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Kolom Pencarian (Search) sesuai di website
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search jadwal ujian...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // State Kosong (No data available in table)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No data available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text('Belum ada jadwal ujian yang dirilis saat ini.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}