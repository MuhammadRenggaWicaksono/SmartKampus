import 'package:flutter/material.dart';
import 'package:app_kampus/profile/biodata_mahasiswa_screen.dart';
import 'package:app_kampus/profile/biodata_keluarga_screen.dart';
import 'package:app_kampus/admin/ganti_password_screen.dart';
import 'package:app_kampus/admin/ganti_password_wifi_screen.dart';
import 'package:app_kampus/komunikasi/pesan_baru_screen.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            const Text('Akun Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 24),

            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  // Avatar dengan tombol kamera untuk upload
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
                          // TODO: Panggil fungsi picker gambar & API upload di sini
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih foto dari galeri...')));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                        const Text('Rengga', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Mahasiswa Aktif', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_square, color: Colors.blue),
                    onPressed: () {}, // Edit profil singkat
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grup Menu: Informasi Pribadi
            _buildMenuGroup(
              title: "INFORMASI PRIBADI",
              children: [
                _buildMenuItem(context, Icons.person_outline, 'Biodata Mahasiswa', const BiodataMahasiswaScreen()),
                _buildMenuItem(context, Icons.family_restroom, 'Biodata Keluarga', const BiodataKeluargaScreen()),
              ],
            ),
            const SizedBox(height: 20),

            // Grup Menu: Keamanan & Komunikasi
            _buildMenuGroup(
              title: "KEAMANAN & KOMUNIKASI",
              children: [
                _buildMenuItem(context, Icons.lock_outline, 'Ganti Password', const GantiPasswordScreen()),
                _buildMenuItem(context, Icons.wifi_password, 'Ganti Password Wifi', const GantiPasswordWifiScreen()),
                _buildMenuItem(context, Icons.chat_bubble_outline, 'Pesan Baru', const PesanBaruScreen()),
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
                  backgroundColor: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup({required String title, required List<Widget> children}) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }
}