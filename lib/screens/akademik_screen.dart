import 'package:flutter/material.dart';
import 'package:app_kampus/akademik/skripsi_screen.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/skripsi_store.dart';
import 'package:app_kampus/studi/entri_krs_screen.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/studi/transkrip_screen.dart';

/// Menu Akademik: KRS, Hasil Studi & Nilai, serta Tugas Akhir & Praktik.
class AkademikScreen extends StatelessWidget {
  const AkademikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Akademik',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: p.textPrimary),
          ),
          body: ValueListenableBuilder<List<PengajuanSkripsi>>(
            valueListenable: SkripsiStore.pengajuan,
            builder: (context, pengajuanSkripsi, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildRingkasan(p),
                const SizedBox(height: 22),

                // --- KELOMPOK 1: KRS ---
                _buildSectionHeader(
                  p,
                  ikon: Icons.edit_note,
                  warna: Colors.orange,
                  judul: 'Kartu Rencana Studi (KRS)',
                  keterangan: 'Pengisian dan riwayat rencana studi',
                ),
                const SizedBox(height: 10),
                _buildMenuGroup(
                  p,
                  children: [
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.edit_document,
                      warna: Colors.orange,
                      judul: 'Entri KRS',
                      keterangan: 'Ajukan atau ubah KRS semester berjalan',
                      lencana: 'Belum diajukan',
                      warnaLencana: p.warning,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IsiKrsScreen()),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.assignment_turned_in,
                      warna: Colors.blue,
                      judul: 'Lihat KRS',
                      keterangan: 'Daftar mata kuliah yang sudah diambil',
                      lencana: '${AppData.sksSemesterIni} SKS',
                      warnaLencana: p.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LihatKrsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // --- KELOMPOK 2: NILAI ---
                _buildSectionHeader(
                  p,
                  ikon: Icons.workspace_premium_outlined,
                  warna: Colors.green,
                  judul: 'Hasil Studi & Nilai',
                  keterangan: 'Nilai akhir, IPS, dan rekap beban SKS',
                ),
                const SizedBox(height: 10),
                _buildMenuGroup(
                  p,
                  children: [
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.grade,
                      warna: Colors.green,
                      judul: 'Lihat KHS',
                      keterangan: 'Nilai per mata kuliah beserta IPS',
                      lencana: 'IPS ${AppData.ipk.toStringAsFixed(2)}',
                      warnaLencana: p.success,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LihatKhsScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.analytics,
                      warna: Colors.purple,
                      judul: 'Rekap Nilai',
                      keterangan: 'Transkrip dan total SKS yang ditempuh',
                      lencana: '${AppData.sksDitempuh} SKS',
                      warnaLencana: p.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TranskripScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // --- KELOMPOK 3: TUGAS AKHIR & PRAKTIK ---
                _buildSectionHeader(
                  p,
                  ikon: Icons.rocket_launch_outlined,
                  warna: Colors.teal,
                  judul: 'Tugas Akhir & Praktik',
                  keterangan: 'Kerja Praktik, KKN, dan penyusunan skripsi',
                ),
                const SizedBox(height: 10),
                _buildMenuGroup(
                  p,
                  children: [
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.work_history,
                      warna: Colors.teal,
                      judul: 'Kerja Praktik (KP)',
                      keterangan: 'Magang di instansi atau industri mitra',
                      lencana: 'Segera',
                      warnaLencana: p.textMuted,
                      onTap: () => _belumTersedia(context, p, 'Kerja Praktik'),
                    ),
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.groups,
                      warna: Colors.brown,
                      judul: 'KKN',
                      keterangan: 'Kuliah Kerja Nyata tematik',
                      lencana: 'Segera',
                      warnaLencana: p.textMuted,
                      onTap: () => _belumTersedia(context, p, 'KKN'),
                    ),
                    _buildMenuItem(
                      context,
                      p,
                      ikon: Icons.school,
                      warna: Colors.indigo,
                      judul: 'Skripsi',
                      keterangan: 'Pengajuan judul, pembimbing, dan tahapan',
                      lencana: pengajuanSkripsi.isEmpty
                          ? 'Belum diajukan'
                          : '${pengajuanSkripsi.length} judul diajukan',
                      warnaLencana: pengajuanSkripsi.isEmpty
                          ? p.warning
                          : p.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SkripsiScreen(),
                        ),
                      ),
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

  void _belumTersedia(BuildContext context, AppPalette p, String nama) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Menu $nama belum tersedia')),
          ],
        ),
        backgroundColor: p.textMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ------------------------------------------------------- kartu ringkasan
  Widget _buildRingkasan(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester ${AppData.sksPerSemester.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppData.semesterAktif,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat('IPK', AppData.ipk.toStringAsFixed(2)),
              _buildStat('SKS', '${AppData.sksDitempuh}/$kSksTargetLulus'),
              _buildStat('MATA KULIAH', '${AppData.mataKuliahAktif.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String nilai) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- judul kelompok
  Widget _buildSectionHeader(
    AppPalette p, {
    required IconData ikon,
    required Color warna,
    required String judul,
    required String keterangan,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(ikon, size: 17, color: warna),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  keterangan,
                  style: TextStyle(fontSize: 11, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ grup menu
  Widget _buildMenuGroup(AppPalette p, {required List<Widget> children}) {
    return Container(
      decoration: p.cardDeco(radius: 16, borderColor: p.border),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 60, color: p.divider),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    AppPalette p, {
    required IconData ikon,
    required Color warna,
    required String judul,
    required String keterangan,
    required VoidCallback onTap,
    String? lencana,
    Color? warnaLencana,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      warna.withValues(alpha: 0.22),
                      warna.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(ikon, color: warna, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      keterangan,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.3,
                        color: p.textSecondary,
                      ),
                    ),
                    if (lencana != null) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (warnaLencana ?? p.accent).withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          lencana,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: warnaLencana ?? p.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(Icons.chevron_right, color: p.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
