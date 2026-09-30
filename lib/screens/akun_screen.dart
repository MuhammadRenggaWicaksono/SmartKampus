import 'package:flutter/material.dart';
import 'package:app_kampus/profile/biodata_mahasiswa_screen.dart';
import 'package:app_kampus/profile/biodata_keluarga_screen.dart';
import 'package:app_kampus/admin/ganti_password_screen.dart';
import 'package:app_kampus/admin/ganti_password_wifi_screen.dart';
import 'package:app_kampus/komunikasi/pesan_baru_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final Color cardColor = isDark
            ? const Color(0xFF1E1E1E)
            : (isLgbt ? Colors.white.withValues(alpha: 0.85) : Colors.white);

        return Container(
          decoration: isLgbt
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                  ),
                )
              : BoxDecoration(color: scaffoldBg),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    Text('Akun Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 24),

                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const CircleAvatar(
                                radius: 35,
                                backgroundColor: Color(0xFF3B82F6),
                                child: Text('RE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih foto dari galeri...')));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rengga', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade900.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Mahasiswa Aktif', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_square, color: Colors.blue),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grup Menu: Informasi Pribadi
                    _buildMenuGroup(
                      title: "INFORMASI PRIBADI",
                      cardColor: cardColor,
                      children: [
                        _buildMenuItem(context, Icons.person_outline, 'Biodata Mahasiswa', textColor, const BiodataMahasiswaScreen()),
                        _buildMenuItem(context, Icons.family_restroom, 'Biodata Keluarga', textColor, const BiodataKeluargaScreen()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Grup Menu: Keamanan & Komunikasi
                    _buildMenuGroup(
                      title: "KEAMANAN & KOMUNIKASI",
                      cardColor: cardColor,
                      children: [
                        _buildMenuItem(context, Icons.lock_outline, 'Ganti Password', textColor, const GantiPasswordScreen()),
                        _buildMenuItem(context, Icons.wifi_password, 'Ganti Password Wifi', textColor, const GantiPasswordWifiScreen()),
                        _buildMenuItem(context, Icons.chat_bubble_outline, 'Pesan Baru', textColor, const PesanBaruScreen()),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tombol Logout
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Keluar Aplikasi', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.red.shade900.withValues(alpha: 0.2) : Colors.red.shade50,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildMenuGroup({required String title, required Color cardColor, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
          ),
          child: Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color textColor, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }
}