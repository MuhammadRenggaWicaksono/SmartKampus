import 'package:flutter/material.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';
import 'package:app_kampus/perkuliahan/jadwal_ujian_screen.dart';
import 'package:app_kampus/akademik/kalender_akademik_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

class PerkuliahanScreen extends StatelessWidget {
  const PerkuliahanScreen({super.key});

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
              title: Text('Perkuliahan', style: TextStyle(color: textColor, fontSize: 18)),
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
                  Text(
                    'Aktivitas Perkuliahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
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
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalKuliahScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Presensi',
                        icon: Icons.how_to_reg_outlined,
                        color: Colors.teal,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Jadwal Ujian',
                        icon: Icons.quiz_outlined,
                        color: Colors.orange,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalUjianScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Kalender Akademik',
                        icon: Icons.event_note_outlined,
                        color: Colors.purple,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalenderAkademikScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}