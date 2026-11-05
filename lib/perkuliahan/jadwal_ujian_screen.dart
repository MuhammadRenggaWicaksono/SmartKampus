import 'package:flutter/material.dart';
import 'package:app_kampus/core/theme_builder.dart';

class JadwalUjianScreen extends StatefulWidget {
  const JadwalUjianScreen({super.key});

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
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Jadwal Ujian', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: Column(
            children: [
              // Kolom Pencarian (Search) sesuai di website
              Container(
                color: p.card,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search jadwal ujian...',
                    prefixIcon: Icon(Icons.search, color: p.textSecondary),
                    filled: true,
                    fillColor: p.inputFill,
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
                      Icon(Icons.event_busy, size: 80, color: p.textSecondary),
                      const SizedBox(height: 16),
                      Text('No data available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: p.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Belum ada jadwal ujian yang dirilis saat ini.', style: TextStyle(fontSize: 13, color: p.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
