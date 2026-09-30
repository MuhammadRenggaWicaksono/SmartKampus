import 'package:flutter/material.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder akan merender ulang halaman ini SAJA 
    // ketika appThemeNotifier berubah nilainya.
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        
        // --- PENGATURAN WARNA BERDASARKAN TEMA GLOBAL ---
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color textColor = isDark ? Colors.white : Colors.black87;
        final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey;
        final Color cardColor = isDark 
            ? const Color(0xFF1E1E1E) 
            : (isLgbt ? Colors.white.withOpacity(0.85) : Colors.white);
        
        final BoxDecoration bgDecoration = isLgbt
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                ),
              )
            : BoxDecoration(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6),
              );

        return Scaffold(
          body: Container(
            decoration: bgDecoration,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Halo, Muhammad 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text('Semester Ganjil 2026/2027', style: TextStyle(color: subTextColor)),
                            ],
                          ),
                        ),
                        // TOMBOL PEMILIH TEMA MENGUBAH VALUE GLOBAL
                        PopupMenuButton<AppThemeMode>(
                          icon: Icon(Icons.palette, color: isLgbt ? Colors.white : textColor),
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          onSelected: (mode) {
                            appThemeNotifier.value = mode; // Ini akan memicu perubahan di SELURUH aplikasi
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: AppThemeMode.light, child: Text('☀️ Light Mode')),
                            const PopupMenuItem(value: AppThemeMode.dark, child: Text('🌙 Dark Mode')),
                            const PopupMenuItem(value: AppThemeMode.lgbt, child: Text('🌈 LGBT Mode')),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'), 
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- JADWAL HARI INI ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Text('Jadwal Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Text('2 KELAS', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildJadwalItem("08.00", "Pemrograman Mobile", "Lab Komputer 3 • Teori & Praktikum", Colors.blue, textColor, subTextColor),
                          const SizedBox(height: 10),
                          _buildJadwalItem("10.00", "Basis Data", "Ruang Aula Utama • Teori", Colors.orange, textColor, subTextColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- INFO AKADEMIK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard("IPK", "3.68", cardColor, textColor, subTextColor),
                        _buildInfoCard("SKS DIAMBIL", "23 SKS", cardColor, textColor, subTextColor),
                        _buildInfoCard("TAGIHAN", "Lunas", cardColor, textColor, subTextColor, isGreen: true),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- MENU CEPAT ---
                    Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildMenuCepatItem(Icons.calendar_month, "Jadwal", Colors.redAccent, cardColor, textColor, () 
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalKuliahScreen()));
                        }),
                        _buildMenuCepatItem(Icons.menu_book, "KRS", Colors.blue, cardColor, textColor, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKrsScreen()));
                        }),
                        _buildMenuCepatItem(Icons.analytics, "KHS", Colors.purple, cardColor, textColor, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKhsScreen()));
                        }),
                        _buildMenuCepatItem(Icons.fact_check, "Presensi", Colors.green, cardColor, textColor, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen()));
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // WIDGET BANTUAN SAMA SEPERTI SEBELUMNYA
  Widget _buildJadwalItem(String time, String title, String subtitle, Color color, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color cardColor, Color textColor, Color subTextColor, {bool isGreen = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 10, color: subTextColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isGreen ? Colors.green : textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCepatItem(IconData icon, String title, Color color, Color cardColor, Color textColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}