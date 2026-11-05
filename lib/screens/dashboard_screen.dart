import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/perkuliahan/jadwal_kuliah_screen.dart';
import 'package:app_kampus/perkuliahan/presensi_screen.dart';
import 'package:app_kampus/profile/avatar_profil.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/theme_notifier.dart';
import 'package:app_kampus/widgets/statistik_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Dipakai supaya label "BERJALAN" / "30 MENIT LAGI" pada jadwal tidak basi.
  Timer? _tick;
  DateTime _sekarang = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _sekarang = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, p),
                    const SizedBox(height: 24),
                    _buildJadwalHariIni(p),
                    const SizedBox(height: 24),
                    _buildInfoAkademik(p),
                    const SizedBox(height: 24),
                    Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCepat(context, p),
                    const SizedBox(height: 24),
                    const StatistikChart(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------- header
  Widget _buildHeader(BuildContext context, AppPalette p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${AppData.namaPanggilan} 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppData.semesterAktif,
                style: TextStyle(color: p.textSecondary),
              ),
            ],
          ),
        ),
        PopupMenuButton<AppThemeMode>(
          icon: Icon(Icons.palette, color: p.textPrimary),
          color: p.card,
          onSelected: (mode) => appThemeNotifier.value = mode,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: AppThemeMode.light,
              child: Text('☀️ Light Mode'),
            ),
            PopupMenuItem(
              value: AppThemeMode.dark,
              child: Text('🌙 Dark Mode'),
            ),
            PopupMenuItem(
              value: AppThemeMode.lgbt,
              child: Text('🌈 LGBT Mode'),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Avatar inisial — sebelumnya memakai URL via.placeholder.com yang
        // sudah mati, jadi gambarnya kosong / gagal terus.
        // Avatar yang sama dengan halaman Akun — ikut berubah begitu foto
        // profil diganti (lewat SupabaseService.fotoProfil), tapi di sini
        // tidak bisa diketuk.
        const AvatarProfil(ukuran: 50, bisaDiubah: false),
      ],
    );
  }

  // ------------------------------------------------------ jadwal hari ini
  Widget _buildJadwalHariIni(AppPalette p) {
    final jadwal = AppData.jadwalTerdekat(_sekarang);
    final berjalan = AppData.kelasSedangBerjalan(_sekarang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        jadwal.hariIni
                            ? 'Jadwal Hari Ini'
                            : 'Jadwal ${jadwal.hari} (berikutnya)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: p.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${jadwal.jumlahMk} KELAS • ${jadwal.totalSks} SKS',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (jadwal.kosong)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.beach_access_outlined,
                    size: 40,
                    color: p.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada kelas hari ini 🎉',
                    style: TextStyle(color: p.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...jadwal.kelas.map(
              (kelas) => Padding(
                padding: EdgeInsets.only(
                  bottom: kelas == jadwal.kelas.last ? 0 : 10,
                ),
                child: _buildJadwalItem(
                  p,
                  kelas,
                  disorot: berjalan != null && berjalan.kode == kelas.kode,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJadwalItem(
    AppPalette p,
    KelasKuliah kelas, {
    required bool disorot,
  }) {
    final status = _statusKelas(kelas, p);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.warna.withValues(alpha: 0.06),
        border: Border.all(
          color: status.warna.withValues(alpha: disorot ? 0.6 : 0.2),
          width: disorot ? 1.6 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: status.warna,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  kelas.jamMulai,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  kelas.jamSelesai,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas.nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${kelas.ruang} • ${kelas.dosen}',
                  style: TextStyle(fontSize: 11, color: p.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status.warna.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: status.warna,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Label status + warnanya untuk satu sesi kuliah.
  ({String label, Color warna}) _statusKelas(KelasKuliah kelas, AppPalette p) {
    if (kelas.sedangBerjalan(_sekarang)) {
      return (label: 'BERJALAN', warna: const Color(0xFF22C55E));
    }

    if (kelas.belumMulai(_sekarang)) {
      final sisa = kelas.menitMulai - (_sekarang.hour * 60 + _sekarang.minute);
      if (sisa <= 60) {
        return (label: '$sisa MENIT LAGI', warna: const Color(0xFFF59E0B));
      }
      return (
        label: '${sisa ~/ 60} JAM ${sisa % 60} MENIT LAGI',
        warna: Colors.blue,
      );
    }

    return (label: 'SELESAI', warna: p.textMuted);
  }

  // ------------------------------------------------------- kartu akademik
  Widget _buildInfoAkademik(AppPalette p) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            p,
            'IPK',
            AppData.ipk.toStringAsFixed(2),
            footer: 'dari 4.00',
          ),
          _buildInfoCard(
            p,
            'SKS DIAMBIL',
            '${AppData.sksSemesterIni} SKS',
            footer: AppData.labelSksTotal,
            footerColor: p.accent,
            progres: AppData.rasioSks,
          ),
          _buildInfoCard(
            p,
            'TAGIHAN',
            AppData.statusTagihan,
            footer: AppData.sisaTagihan,
            nilaiColor: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    AppPalette p,
    String judul,
    String nilai, {
    String? footer,
    Color? footerColor,
    Color? nilaiColor,
    double? progres,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: p.cardDeco(radius: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              judul,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: p.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nilai,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: nilaiColor ?? p.textPrimary,
              ),
            ),
            if (progres != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progres.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: p.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 6),
              Text(
                footer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: footerColor ?? p.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- menu cepat
  Widget _buildMenuCepat(BuildContext context, AppPalette p) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildMenuCepatItem(
          p,
          Icons.calendar_month,
          'Jadwal',
          Colors.redAccent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JadwalKuliahScreen()),
          ),
        ),
        _buildMenuCepatItem(
          p,
          Icons.menu_book,
          'KRS',
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LihatKrsScreen()),
          ),
        ),
        _buildMenuCepatItem(
          p,
          Icons.analytics,
          'KHS',
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LihatKhsScreen()),
          ),
        ),
        _buildMenuCepatItem(
          p,
          Icons.fact_check,
          'Presensi',
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PresensiScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCepatItem(
    AppPalette p,
    IconData ikon,
    String judul,
    Color warna,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: p.cardDeco(radius: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, color: warna),
              const SizedBox(width: 8),
              Text(
                judul,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
