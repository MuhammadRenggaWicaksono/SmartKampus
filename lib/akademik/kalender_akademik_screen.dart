import 'package:flutter/material.dart';
import 'package:app_kampus/core/theme_builder.dart';

class KalenderAkademikScreen extends StatelessWidget {
  const KalenderAkademikScreen({super.key});

  void _downloadKalender(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh Kalender Akademik (PDF)...'), backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Kalender Akademik', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
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
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(Icons.picture_as_pdf_outlined, size: 80, color: Colors.blue.shade300),
                ),
                const SizedBox(height: 24),
                Text('Kalender Akademik 2026/2027', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p.textPrimary)),
                const SizedBox(height: 8),
                Text('Ketuk tombol di bawah untuk melihat kalender.', style: TextStyle(color: p.textSecondary)),
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
        ),
      ),
    );
  }
}
