import 'package:flutter/material.dart';
import 'package:app_kampus/studi/isi_krs_screen.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/studi/transkrip_screen.dart';

class AkademikScreen extends StatelessWidget {
  const AkademikScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Akademik', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, // Hilangkan tombol back jika ini menu utama di bottom nav
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KELOMPOK 1: KRS ---
            _buildSectionTitle('Kartu Rencana Studi (KRS)'),
            _buildMenuGroup(
              children: [
                _buildMenuItem(
                  context,
                  title: 'Entri KRS',
                  icon: Icons.edit_document,
                  iconColor: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IsiKrsScreen())),
                ),
                const Divider(height: 1, indent: 56), // Garis pembatas
                _buildMenuItem(
                  context,
                  title: 'Lihat KRS',
                  icon: Icons.assignment_turned_in,
                  iconColor: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKrsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- KELOMPOK 2: NILAI ---
            _buildSectionTitle('Hasil Studi & Nilai'),
            _buildMenuGroup(
              children: [
                _buildMenuItem(
                  context,
                  title: 'Lihat KHS',
                  icon: Icons.grade,
                  iconColor: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKhsScreen())),
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  title: 'Rekap Nilai',
                  icon: Icons.analytics,
                  iconColor: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranskripScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- KELOMPOK 3: TUGAS AKHIR & PRAKTIK ---
            _buildSectionTitle('Tugas Akhir & Praktik'),
            _buildMenuGroup(
              children: [
                _buildMenuItem(
                  context,
                  title: 'Kerja Praktik (KP)',
                  icon: Icons.work_history,
                  iconColor: Colors.teal,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Kerja Praktik belum tersedia'))),
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  title: 'KKN',
                  icon: Icons.groups,
                  iconColor: Colors.brown,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu KKN belum tersedia'))),
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  title: 'Skripsi',
                  icon: Icons.school,
                  iconColor: Colors.indigo,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Skripsi belum tersedia'))),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget untuk Judul Kategori
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700, letterSpacing: 0.5),
      ),
    );
  }

  // Widget untuk membungkus list menu agar berbentuk seperti Card membulat
  Widget _buildMenuGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Widget untuk masing-masing baris menu
  Widget _buildMenuItem(BuildContext context, {required String title, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}