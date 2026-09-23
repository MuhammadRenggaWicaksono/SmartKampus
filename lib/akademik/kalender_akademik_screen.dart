import 'package:flutter/material.dart';

class KalenderAkademikScreen extends StatelessWidget {
  const KalenderAkademikScreen({Key? key}) : super(key: key);

  void _downloadKalender(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh Kalender Akademik (PDF)...'), backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kalender Akademik', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.blue),
            tooltip: 'Download PDF',
            onPressed: () => _downloadKalender(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: Icon(Icons.picture_as_pdf_outlined, size: 80, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 24),
            const Text('Kalender Akademik 2026/2027', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ketuk tombol di bawah untuk melihat kalender.', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Buka halaman PDF Viewer jika package sudah diinstal
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur PDF Viewer akan segera hadir')));
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Lihat PDF Kalender'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}