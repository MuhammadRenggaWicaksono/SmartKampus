import 'package:flutter/material.dart';
import 'package:app_kampus/auth/login_screen.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/diagnostik_screen.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/supabase_service.dart';
import 'package:app_kampus/profile/avatar_profil.dart';
import 'package:app_kampus/profile/biodata_mahasiswa_screen.dart';
import 'package:app_kampus/profile/biodata_keluarga_screen.dart';
import 'package:app_kampus/admin/ganti_password_screen.dart';
import 'package:app_kampus/admin/ganti_password_wifi_screen.dart';
import 'package:app_kampus/komunikasi/pesan_baru_screen.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  /// Keluar dari aplikasi: akhiri sesi Supabase (kalau ada) lalu kembali
  /// ke halaman login.
  Future<void> _keluar(BuildContext context) async {
    await SupabaseService.keluar();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    Text(
                      'Akun Saya',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfilHeader(context, p),
                    const SizedBox(height: 24),
                    _buildMenuGroup(
                      p,
                      title: 'INFORMASI PRIBADI',
                      children: [
                        _buildMenuItem(
                          context,
                          p,
                          Icons.person_outline,
                          'Biodata Mahasiswa',
                          const BiodataMahasiswaScreen(),
                        ),
                        _buildMenuItem(
                          context,
                          p,
                          Icons.family_restroom,
                          'Biodata Keluarga',
                          const BiodataKeluargaScreen(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMenuGroup(
                      p,
                      title: 'KEAMANAN & KOMUNIKASI',
                      children: [
                        _buildMenuItem(
                          context,
                          p,
                          Icons.lock_outline,
                          'Ganti Password',
                          const GantiPasswordScreen(),
                        ),
                        _buildMenuItem(
                          context,
                          p,
                          Icons.wifi_password,
                          'Ganti Password Wifi',
                          const GantiPasswordWifiScreen(),
                        ),
                        _buildMenuItem(
                          context,
                          p,
                          Icons.chat_bubble_outline,
                          'Pesan Baru',
                          const PesanBaruScreen(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMenuGroup(
                      p,
                      title: 'SISTEM',
                      children: [
                        _buildMenuItem(
                          context,
                          p,
                          Icons.health_and_safety_outlined,
                          'Diagnostik Supabase',
                          const DiagnostikScreen(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _keluar(context),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Keluar Aplikasi',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(
                            alpha: p.isDark ? 0.22 : 0.08,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
      },
    );
  }

  Widget _buildProfilHeader(BuildContext context, AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: p.cardDeco(radius: 20),
      child: Row(
        children: [
          // Avatar yang bisa diubah: ketuk avatar atau ikon kamera untuk
          // memilih foto dari galeri / kamera, lalu diunggah ke Supabase
          // Storage dan disimpan di profiles.foto_url.
          const AvatarProfil(ukuran: 70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppData.namaPanggilan,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIM ${AppData.nim}',
                  style: TextStyle(fontSize: 12, color: p.textSecondary),
                ),
                if (SupabaseService.user?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      SupabaseService.user!.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: p.textMuted),
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mahasiswa Aktif',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(
    AppPalette p, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: p.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: p.shadow, blurRadius: 10)],
          ),
          child: Material(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    AppPalette p,
    IconData icon,
    String title,
    Widget destination,
  ) {
    return ListTile(
      leading: Icon(icon, color: p.accentText),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: p.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: p.textMuted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
