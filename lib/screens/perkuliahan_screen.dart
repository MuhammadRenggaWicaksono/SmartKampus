import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';
import 'package:app_kampus/perkuliahan/jadwal_ujian_screen.dart';
import 'package:app_kampus/akademik/kalender_akademik_screen.dart';

class PerkuliahanScreen extends StatelessWidget {
  const PerkuliahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Perkuliahan', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: p.textPrimary),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivitas Perkuliahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: p.textPrimary),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Jadwal Kuliah',
                      icon: Icons.calendar_month_outlined,
                      color: Colors.blue,
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalKuliahScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Presensi',
                      icon: Icons.how_to_reg_outlined,
                      color: Colors.teal,
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Jadwal Ujian',
                      icon: Icons.quiz_outlined,
                      color: Colors.orange,
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalUjianScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Kalender Akademik',
                      icon: Icons.event_note_outlined,
                      color: Colors.purple,
                      p: p,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalenderAkademikScreen())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required AppPalette p,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: p.cardDeco(radius: 16, borderColor: p.border),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: p.textPrimary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
