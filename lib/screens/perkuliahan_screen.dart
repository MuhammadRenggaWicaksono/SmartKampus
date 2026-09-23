import 'package:flutter/material.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';
import 'package:app_kampus/perkuliahan/jadwal_ujian_screen.dart';
import 'package:app_kampus/akademik/kalender_akademik_screen.dart';

class PerkuliahanScreen extends StatelessWidget {
  const PerkuliahanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Perkuliahan', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas Perkuliahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalKuliahScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Presensi',
                  icon: Icons.how_to_reg_outlined,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Jadwal Ujian',
                  icon: Icons.quiz_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalUjianScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Kalender Akademik',
                  icon: Icons.event_note_outlined,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalenderAkademikScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}