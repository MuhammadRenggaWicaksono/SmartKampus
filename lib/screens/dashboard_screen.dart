import 'package:flutter/material.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Header Profil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Halo, Muhammad 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Semester Ganjil 2026/2027', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Ganti dengan asset aslimu
                )
              ],
            ),
            const SizedBox(height: 24),

            // Card Jadwal Hari Ini
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calendar_month, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Jadwal Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Text('2 KELAS', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // List Jadwal
                  _buildJadwalItem("08.00", "Pemrograman Mobile", "Lab Komputer 3 • Teori & Praktikum", Colors.blue),
                  const SizedBox(height: 10),
                  _buildJadwalItem("10.00", "Basis Data", "Ruang Aula Utama • Teori", Colors.orange),
                  const SizedBox(height: 12),
                  
                  // UPDATE: Diubah menjadi TextButton agar bisa diklik
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Row Info Akademik (IPK, SKS, Tagihan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard("IPK", "3.68"), // Aku sesuaikan IPK dari data KHS kamu
                _buildInfoCard("SKS DIAMBIL", "23 SKS"), // Disesuaikan dari data KHS Ganjil 2024/2025
                _buildInfoCard("TAGIHAN", "Lunas", isGreen: true),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Cepat
            const Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                // UPDATE: Menambahkan fungsi onTap untuk masing-masing menu
                _buildMenuCepatItem(Icons.calendar_month, "Jadwal", Colors.redAccent, () {
                  // Arahkan ke halaman Jadwal Kuliah yang sudah kita buat
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalKuliahScreen()));
                }),
                _buildMenuCepatItem(Icons.menu_book, "KRS", Colors.blue, () {
                  // Arahkan ke halaman KRS yang sudah kita buat
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKrsScreen()));
                }),
                _buildMenuCepatItem(Icons.analytics, "KHS", Colors.purple, () {
                  // Arahkan ke halaman KHS yang sudah kita buat
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKhsScreen()));
                }),
                _buildMenuCepatItem(Icons.fact_check, "Presensi", Colors.green, () {
                  // Arahkan ke halaman Presensi yang sudah kita buat
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen()));
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget bantuan untuk jadwal
  Widget _buildJadwalItem(String time, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget bantuan untuk card IPK dll
  Widget _buildInfoCard(String title, String value, {bool isGreen = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)]
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isGreen ? Colors.green : Colors.black)),
          ],
        ),
      ),
    );
  }

  // UPDATE: Menambahkan parameter "VoidCallback onTap" dan widget InkWell
  Widget _buildMenuCepatItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // Menjalankan fungsi yang dikirim ke parameter
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}