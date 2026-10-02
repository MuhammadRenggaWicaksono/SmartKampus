import 'package:flutter/material.dart';
import 'package:app_kampus/studi/entri_krs_screen.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/studi/transkrip_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

class AkademikScreen extends StatelessWidget {
  const AkademikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final Color textColor = isDark ? Colors.white : Colors.black87;
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
            appBar: AppBar(
              title: Text('Akademik', style: TextStyle(color: textColor, fontSize: 18)),
              backgroundColor: cardColor,
              elevation: 0.5,
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: textColor),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KELOMPOK 1: KRS ---
                  _buildSectionTitle('Kartu Rencana Studi (KRS)', isDark),
                  _buildMenuGroup(
                    cardColor: cardColor,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Entri KRS',
                        icon: Icons.edit_document,
                        iconColor: Colors.orange,
                        textColor: textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IsiKrsScreen())),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildMenuItem(
                        context,
                        title: 'Lihat KRS',
                        icon: Icons.assignment_turned_in,
                        iconColor: Colors.blue,
                        textColor: textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKrsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- KELOMPOK 2: NILAI ---
                  _buildSectionTitle('Hasil Studi & Nilai', isDark),
                  _buildMenuGroup(
                    cardColor: cardColor,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Lihat KHS',
                        icon: Icons.grade,
                        iconColor: Colors.green,
                        textColor: textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatKhsScreen())),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildMenuItem(
                        context,
                        title: 'Rekap Nilai',
                        icon: Icons.analytics,
                        iconColor: Colors.purple,
                        textColor: textColor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranskripScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- KELOMPOK 3: TUGAS AKHIR & PRAKTIK ---
                  _buildSectionTitle('Tugas Akhir & Praktik', isDark),
                  _buildMenuGroup(
                    cardColor: cardColor,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Kerja Praktik (KP)',
                        icon: Icons.work_history,
                        iconColor: Colors.teal,
                        textColor: textColor,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Kerja Praktik belum tersedia'))),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildMenuItem(
                        context,
                        title: 'KKN',
                        icon: Icons.groups,
                        iconColor: Colors.brown,
                        textColor: textColor,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu KKN belum tersedia'))),
                      ),
                      Divider(height: 1, indent: 56, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      _buildMenuItem(
                        context,
                        title: 'Skripsi',
                        icon: Icons.school,
                        iconColor: Colors.indigo,
                        textColor: textColor,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Skripsi belum tersedia'))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuGroup({required Color cardColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: cardColor == const Color(0xFF1E1E1E) ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
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