import 'package:flutter/material.dart';
import 'package:app_kampus/core/theme_builder.dart';

class TranskripScreen extends StatelessWidget {
  const TranskripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Transkrip Nilai', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 80, color: Colors.purple.shade200),
                const SizedBox(height: 16),
                Text('Transkrip Kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: p.textPrimary)),
                const SizedBox(height: 8),
                Text('Riwayat nilai Anda akan muncul di sini.', style: TextStyle(color: p.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
